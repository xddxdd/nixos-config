# fastpit

A Rust HTTP server that serves an unlimited, realistic-looking blog. Every page
is generated deterministically from a Cap'n Proto corpus (`corpus.bin`) of POS
sentence templates and word pools, rendered through the HTML template in
`assets/`. No files are written; any URL renders a page.

- **Deterministic.** A page's bytes are identical on every refresh and after a
  server restart. The RNG for a request is seeded from `(global_seed, path)`.
- **Unlimited.** Any path that looks like a page renders HTML; known
  asset extensions are served from the asset directory.
- **Tarpit.** Many parallel connections are held cheaply by an async
  multi-threaded server (tokio + axum) with a shared, bounded, sharded cache.

The data-generation pipeline is documented in
[`data/README.md`](data/README.md); the corpus format is specified by
[`data/corpus.capnp`](data/corpus.capnp) and
[`data/FORMAT.md`](data/FORMAT.md). The rest of this document covers the
server.

## Server

### Build and run

`fastpit` is a package inside the `nixos-config` repository, built by
[`pkgs/fastpit/default.nix`](default.nix) with
`rustPlatform.buildRustPackage`. Build and evaluate it from the repo root:

```
nix-build -E 'with (import <nixpkgs> {}); callPackage ./pkgs/fastpit {}' -o /tmp/fastpit-build
```

Inside a NixOS module, use this repo's convention
(`nixos/optional-apps/pipewire-volume-control.nix` is an example):

```nix
pkgs.callPackage ./pkgs/fastpit { }
```

`build.rs` compiles `data/corpus.capnp` with `capnpc`, so the Cap'n Proto
compiler must be on `PATH` at build time; `default.nix` adds `capnproto` to
`nativeBuildInputs`. For Rust development inside the repo, wrap cargo in a
`nix-shell` — the `cargo` on `PATH` has a broken linker:

```
nix-shell -p cargo rustc capnproto --run 'cargo run -- --port 8080'
```

Release builds use LTO and a single codegen unit (`[profile.release]` in
`Cargo.toml`):

```
nix-shell -p cargo rustc capnproto --run 'cargo build --release'
```

The corpus is embedded in the binary at compile time, so the built server needs
no corpus file. Assets are **not** embedded: `default.nix`'s `postInstall`
copies them to `$out/share/fastpit/assets`, so a deployed service must pass
`--asset-dir $out/share/fastpit/assets`; running from a checkout, the default
`assets` directory still works. At startup the `--asset-dir`
directory (default `assets`) is scanned and every regular file is loaded, keyed
by its lowercase extension only — there is no MIME-type allowlist.

`--asset-dir` selects the assets; a deployed service must pass
`--asset-dir $out/share/fastpit/assets`. `--data-file` memory-maps a packed
`corpus.bin` instead of the embedded copy. `corpus.bin` is the only corpus
format the server accepts — there is no JSON corpus input at runtime. The page
template is **not** part of the corpus: it is an asset, the single `.html` file
in `--asset-dir`. `corpus.bin` holds only words, tags, pools, the POS sentence
templates and the generation parameters, so its packed bytes contain no
`{MAIN}`, `<!DOCTYPE` or `<html`.

### CLI flags

| flag | default | meaning |
|------|---------|---------|
| `--host <ip>` | `127.0.0.1` | bind address |
| `--port <u16>` | `8080` | bind port |
| `--socket <path>` | none | bind a unix socket instead of TCP; `--host`/`--port` are ignored |
| `--seed <u64>` | `0` | global seed / salt |
| `--document-root <path>` | `/` | sub-path deployment prefix |
| `--workers <n>` | `0` = available_parallelism | tokio worker threads |
| `--cache-size <n>` | `2048` | max cached pages, `0` disables |
| `--asset-dir <path>` | `assets` | directory of assets, keyed by file extension; the single `.html` file is the page template |
| `--data-file <path>` | none | memory-map a `corpus.bin` produced by `data/corpus.py pack` instead of the embedded corpus |
| `--help` | | usage, exit 0 |

Unknown flags print usage to stderr and exit 2. A bad asset directory or a
`corpus.bin` that fails to load prints an error to stderr and exits 1.

### Unix socket

With `--socket <path>` the server listens **only** on a Unix domain socket and
ignores `--host` / `--port`. Any stale socket file left at that path by a
previous run is removed before binding, and the startup line reports
`unix:<path>`. After binding, the socket file is chmod'd to `0770`; this is
best-effort, so a failed chmod is ignored and the server keeps running. Point
nginx at it with:

```nginx
proxyPass = "http://unix:/run/fastpit/fastpit.sock";
```

### Routing

One fallback handler serves every path:

- Any method other than `GET`/`HEAD` -> `404` with an empty body.
- If the last path segment's lowercase extension (the part after its last `.`)
  is a loaded asset extension -> `200` with those bytes. The `Content-Type` is
  guessed from the extension name with the `mime_guess` crate, falling back to
  `application/octet-stream` for an unknown extension: `.css` -> `text/css`,
  `.txt` -> `text/plain`, `.png` -> `image/png`, `.jpg` -> `image/jpeg`,
  `.ico` -> `image/x-icon`, and an arbitrary `.foo` ->
  `application/octet-stream`. There is no special case for `/robots.txt`; it is
  served because `txt` is loaded.
- Else if the last segment contains a `.` -> `404` (unknown extension).
- Else -> render a page: `200` `text/html; charset=utf-8`.

`HEAD` returns the same status, `Content-Type` and `Content-Length` as the
matching `GET`, with an empty body.

Asset loading is strict so that mistakes fail at startup, not per request: a
missing or unreadable asset directory, a file with no extension, two files
sharing an extension, and an asset directory without an `.html` file are all
startup errors that name the offending file. The extension name is not checked
against a content-type allowlist: any extension is accepted, and an unknown one
is simply served as `application/octet-stream`.

### Determinism

The seed for a request is

```
Rng::new(fnv1a64(path) ^ global_seed.wrapping_mul(0x9E3779B97F4A7C15))
```

so the same path yields the same page under the same `--seed`, across restarts
and independent of the cache. Changing `--seed` changes every page; two
different paths differ. Link, title, name and path generation all draw from the
same per-request RNG stream.

The generator is deterministic but not frozen: it now uses `Xoshiro256++`
(`rand_xoshiro`) instead of the original hand-written SplitMix64, so the text a
given `(seed, path)` produces differs from older builds. Everything above —
stability across refresh/restart — still holds.

### Performance and caching

- tokio multi-threaded runtime; `--workers 0` uses `available_parallelism`.
- Shared `Arc<App>` state; the corpus index, the assets and the template are
  read-only.
- The corpus is either embedded in the binary or memory-mapped from
  `--data-file` (`src/mmap.rs`, `memmap2`, with `Advice::Random`). It is a
  standard Cap'n Proto message, but the server traverses it **once at load
  time**: it validates the message and copies the generation index (word blob
  offset/length, `wordOffsets`, `universeLen`, `tagStrings`,
  `contentOff`/`functionOff`, `punctString`, `contentItems`/`functionItems`,
  `templateOff`/`templateTags`, and the parameters) into plain `Vec`s, then
  drops the reader. No `capnp::message::Reader` is retained and no pointer is
  followed per request. Word strings stay zero-copy slices of the
  mapped/embedded bytes.
- Rendering is two-pass and buffer-reusing. Pass 1 performs every RNG draw in
  document order and stores the results; pass 2 assembles the page once into a
  preallocated buffer. Sentences, paragraphs and link runs are appended into
  caller-owned buffers (`SentenceScratch`, `get_header_into`/`get_para_into`,
  `add_links_into`) instead of allocating a fresh `String` per word or sentence.
- A bounded response cache is split into 32 shards (`fnv1a64(path) % 32`), each
  a small `Mutex<HashMap<...>>`. The lock is held only for a get/insert.
  Per-shard capacity is `max(1, cache_size / 32)`; when a shard is full it is
  cleared (hot paths survive between clears, memory stays bounded). The cache
  stores `Bytes`, so a hit clones an atomic refcount only — O(1), no copy.
- Release profile uses LTO + 1 codegen unit.

The cache is only an optimization: the same path renders byte-identical pages
with `--cache-size 0`.

#### Why the render path was rewritten

A `perf` profile plus a worker-scaling sweep found that uncached rendering did
not scale at all: CPU per page grew linearly with worker count while throughput
stayed flat at ~250 req/s. With the `capnp` `sync_reader` feature enabled,
capnp's shared `ReadLimiter` is an `AtomicUsize` and **every** pointer follow
did an atomic `load` *and* `store` on the same cache line, so all workers
ping-ponged that one line. Secondary costs were a `String` allocation per word,
a multi-pass `str::replace` for escaping, and `memmove` from growing buffers.
The rewrite removes the shared reader (the index is copied once at load), draws
all random values before writing any output, and reuses preallocated buffers.

Measured on a 16 vCPU i7-11800H, loopback, release build, `--seed 7`, uncached
(`--cache-size 0`), random paths from `wrk -s /tmp/rand.lua`, concurrency 64,
6 s; per-page CPU is `utime + stime` from `/proc/PID/stat` divided by the
requests served:

| workers | before req/s | before CPU/page | after req/s | after CPU/page |
|--------:|-------------:|----------------:|------------:|---------------:|
| 1       | 438          | 2.25 ms         | 3,314       | 0.29 ms        |
| 2       | 411          | 4.82 ms         | 6,381       | 0.30 ms        |
| 4       | 279          | 14.18 ms        | 12,268      | 0.31 ms        |
| 8       | 293          | 27.06 ms        | 22,759      | 0.34 ms        |
| 16      | 241          | 63.82 ms        | 33,775      | 0.42 ms        |

With the default cache (`--cache-size 2048`), an `oha` matrix measured a cached
page at 45,630 req/s at concurrency 1 and 176,366 req/s at concurrency 64; the
uncached render path reached 31,962 req/s at concurrency 64 and 24,031 req/s at
concurrency 4096. A 239 KB CSS asset served ~19–26k req/s and is
bandwidth-bound.

## Data generation

The offline data pipeline, the Cap'n Proto corpus format and the exact
regeneration commands are documented in
[`data/README.md`](data/README.md) and [`data/FORMAT.md`](data/FORMAT.md).
`data/templates.json` and `data/word_pools.json` are pack inputs only — the
server never reads them. In short: `python3 data/corpus.py extract` mines
templates and word pools from the nltk treebank into `data/templates.json` +
`data/word_pools.json`, `python3 data/corpus.py pack` writes them into
`data/corpus.bin` (the only runtime corpus, embedded into the server or
memory-mapped via `--data-file`), `all` runs both, and `generate` prints sample
sentences. Re-run the packer after every JSON change and recompile for a
release build.

The runtime corpus currently holds 1,788 templates after dropping the six
treebank `LS` templates, 43 tags and 76,270 distinct strings (71,431 of them
the word universe) in 1,371,024 bytes, sha256
`2214d87d8aeb027c4c0e702213ed7d5e91e4816223d9b9e62918d769a4e6f72a`.
