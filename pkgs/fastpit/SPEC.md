# fastpit — implementation spec

Rust rewrite of the Pyison LLM tarpit. It serves an unlimited, realistic-looking
blog whose pages are generated deterministically from a Cap'n Proto corpus
(`data/corpus.bin`, packed offline from `data/templates.json` +
`data/word_pools.json`), rendered through the HTML template in `assets/`. The
server accepts `corpus.bin` and nothing else, and the template is an asset, not
corpus data.

## Hard requirements

1. **Deterministic per-page content.** A page's bytes must be identical on every
   refresh and after a server restart. The RNG for a request is seeded from
   `(global_seed, request_path)`.
2. **Unlimited pages.** No files are written; any path renders a page.
3. **Realistic site.** Assets come from a directory (`--asset-dir`, default
   `assets`): the single `.html` file is the page template, and
   `assets/style.css`, `assets/logo.{ico,jpg,png}`, `assets/robots.txt` are
   served by extension.
4. **Sentences from the data/ corpus.** `{SENTENCE}` / `{MAIN}` bodies are POS
   templates filled from the word pools. The corpus is a self-contained Cap'n
   Proto message; the server validates it once at load, copies its generation
   index into owned tables (word strings stay zero-copy slices) and hardcodes
   no tag name.
5. **Performance under many parallel connections.** Async multi-threaded server
   (tokio + axum), HTTP/1.1 keep-alive, shared `Arc` state, bounded sharded
   response cache.

## Layout

```
Cargo.toml
build.rs         capnpc compiles data/corpus.capnp -> $OUT_DIR/corpus_capnp.rs
src/main.rs      CLI parse, asset + corpus load, runtime build, bind + serve
src/app.rs       App state, routing, response cache, request handler
src/corpus.rs    Cap'n Proto corpus load (one-time index copy) + sentence generation
src/mmap.rs      memmap2 mapping of corpus.bin (one of two `unsafe` sites)
src/rng.rs       fnv1a64 + Xoshiro256++ Rng
src/page.rs      path/title/link generation + HTML tag substitution
src/assets.rs    extension-keyed asset directory loading
assets/          template.html style.css logo.ico logo.jpg logo.png robots.txt
data/            corpus.capnp corpus.py templates.json word_pools.json corpus.bin
                 README.md FORMAT.md   (templates.json/word_pools.json are pack inputs only)
default.nix      rustPlatform.buildRustPackage (src = ./.); postInstall copies assets to $out/share/fastpit/assets
AGENTS.md        project guide
README.md        usage
```

## Dependencies (Cargo.toml)

```toml
[package]
name = "fastpit"
version = "0.1.0"
edition = "2021"
build = "build.rs"

[dependencies]
axum = "0.8"
tokio = { version = "1", features = ["rt-multi-thread", "net"] }
capnp = { version = "0.25", features = ["unaligned"] }
memmap2 = "0.9"
rand = "0.9"
rand_xoshiro = "0.7"
fnv = "1"
mime_guess = "2"

[build-dependencies]
capnpc = "0.25"

[profile.release]
lto = true
codegen-units = 1
```

Binary name: `fastpit`. `build.rs` runs

```rust
capnpc::CompilerCommand::new()
    .src_prefix("data")
    .file("data/corpus.capnp")
    .run()
```

so the Cap'n Proto compiler must be on `PATH` at build time (the package's
`nativeBuildInputs` includes `capnproto`).

## CLI (hand-rolled, no clap)

| flag | default | meaning |
|------|---------|---------|
| `--host <ip>` | `127.0.0.1` | bind address |
| `--port <u16>` | `8080` | bind port |
| `--socket <path>` | none | bind a unix socket instead of TCP; `--host` / `--port` are ignored |
| `--seed <u64>` | `0` | global seed / salt |
| `--document-root <path>` | `/` | sub-path deployment prefix |
| `--workers <n>` | `0` = available_parallelism | tokio worker threads |
| `--cache-size <n>` | `2048` | max cached pages, `0` disables |
| `--asset-dir <path>` | `assets` | asset directory (extension-keyed) |
| `--data-file <path>` | none | mmap a packed `corpus.bin` instead of the embedded corpus |
| `--help` / `-h` | | usage, exit 0 |

Unknown flag or missing/invalid value -> usage to stderr, exit 2. Asset or
`corpus.bin` load failure -> stderr, exit 1. `corpus.bin` is the only supported
corpus format; there is no JSON corpus input at runtime.

## src/rng.rs

```rust
pub fn fnv1a64(bytes: &[u8]) -> u64;          // FNV-1a 64-bit, via `fnv::FnvHasher`

pub struct Rng { inner: Xoshiro256PlusPlus }
impl Rng {
    pub fn new(seed: u64) -> Rng;             // Xoshiro256PlusPlus::seed_from_u64
    pub fn next_u64(&mut self) -> u64;
    pub fn below(&mut self, n: u64) -> u64;   // unbiased uniform in [0, n), n > 0
    pub fn range_inc(&mut self, lo: i64, hi: i64) -> i64; // inclusive [lo, hi]
    pub fn usize(&mut self, lo: usize, hi_excl: usize) -> usize;
    pub fn choice<'a, T>(&mut self, items: &'a [T]) -> Option<&'a T>;
    pub fn boolean(&mut self) -> bool;
}
```

`below` delegates to `rand`'s `random_range`, which is Lemire's widening-multiply
method with rejection, so it is unbiased. Everything must be pure and
reproducible.

Note: replacing the original hand-written SplitMix64 with `Xoshiro256++` changed
the generated text for a given `(seed, path)`. Determinism across
refresh/restart is unaffected.

## src/corpus.rs

The schema is `data/corpus.capnp`; the field meanings are documented in
`data/FORMAT.md`. The message is version 4 with magic `0x0054495054534146`
(`b"FASTPIT\0"` little-endian). Its fields are `wordBlob` / `wordOffsets` /
`universeLen`, `tagStrings`, `contentOff` / `functionOff` / `punctString` /
`contentItems` / `functionItems`, `templateOff` / `templateTags`, and the
generation parameters `numberTag` / `numberMin` / `numberMax` / `flags` /
`attach`. There are no separate count fields and no `schemaText` copy: the
counts are the list lengths (`wordCount = len(wordOffsets) - 1`,
`tagCount = len(tagStrings) = len(contentOff) - 1 = len(functionOff) - 1`,
`templateCount = len(templateOff) - 1`). At load the server builds a transient
`Reader<BufferSegments<..>>` over the embedded bytes or the mmap, validates it,
copies the generation index into owned tables and drops the reader. No reader is
retained, so request-time access never follows a Cap'n Proto pointer (which
would touch the shared atomic read limiter). Word strings stay zero-copy slices
of the underlying buffer:

```rust
pub enum CorpusBytes { Static(&'static [u8]), Mapped(Mmap), Owned(Vec<u8>) }

pub struct Corpus { bytes: CorpusBytes, index: Index }  // Index = owned Vecs

impl Corpus {
    pub fn embedded() -> Corpus;                        // include_bytes!("../data/corpus.bin")
    pub fn from_file(path: &Path) -> Result<Corpus, String>;   // memmap2
    pub fn from_owned(bytes: Vec<u8>) -> Result<Corpus, String>; // test helper
    // accessors: string, universe_word, number_tag/min/max, article_fix,
    // capitalize_first, attach, tag_name, content_len/item, function_len/item,
    // punct, template_count/len/tag
}

pub struct SentenceScratch { /* reused word list + number buffer */ }

pub fn generate_sentence(rng: &mut Rng, corpus: &Corpus, out: &mut String);
pub fn generate_sentence_with(rng: &mut Rng, corpus: &Corpus, out: &mut String,
                              scratch: &mut SentenceScratch);
```

- Strings are returned as `&str` slices of the underlying buffer
  (`wordBlob[wordOffsets[i] .. wordOffsets[i+1]]`), read with the single
  `unsafe` `core::str::from_utf8_unchecked` in `Corpus::string`; the safety
  invariant is the load-time UTF-8 check over every word slice. There is no
  parsing, no `HashMap` and no per-word allocation on the request path.
- `ReaderOptions::traversal_limit_in_words` is set to `None` because the limit
  is cumulative per reader and the whole message is walked once at load time.
- `validate` checks magic, version, the derived counts (`wordCount =
  len(wordOffsets) - 1`, `tagCount = len(tagStrings) = len(punctString) =
  len(attach) = len(contentOff) - 1 = len(functionOff) - 1`,
  `templateCount = len(templateOff) - 1`), monotonic offsets, UTF-8, pool ranges,
  word-id ranges, `universeLen`, `numberTag`, `numberMin <= numberMax` and
  `attach` values, then copies every field into the `Index`. Corrupt input is
  reported as an error; a panic inside the `capnp` traversal is caught with
  `catch_unwind` and turned into `"corpus is corrupt: validation panicked"`.
- The corpus holds only words, tags, pools, the POS sentence templates and the
generation parameters. The page template is **not** inside `corpus.bin`; it is
the `.html` asset loaded from `--asset-dir`. The packed bytes contain no
`{MAIN}`, `<!DOCTYPE` or `<html`.

### generate_sentence

`generate_sentence_with` appends one sentence into `&mut String` and reuses the
caller's `SentenceScratch` (word list + number formatting buffer), so a whole
paragraph builds in one buffer with no per-sentence allocation;
`generate_sentence` is the scratch-less convenience wrapper. The RNG draw order
is unchanged: the template draw, then one draw per slot in order, and all slots
are drawn before any of them is written (so article agreement still sees the
untouched successor word).

All generation parameters come from the message (`numberTag`, `numberMin`,
`numberMax`, `flags`, `attach`); the standard corpus's values are
`numberTag = CD`, `1..=100`, flags `0b11`, and the `attach` spacing map
documented in `data/FORMAT.md`.

- Pick a template uniformly at random.
- For each tag:
  - tag == `numberTag` -> `rng.range_inc(numberMin, numberMax)`, formatted
    lazily into the scratch number buffer.
  - tag has a punct string -> the literal punctuation char.
  - tag has a non-empty content pool -> random word (the pool already includes
    the merged WordNet base forms for `NN`/`VB`/`JJ`/`RB`).
  - tag has a non-empty function pool -> random word.
  - otherwise -> the tag name (cannot happen for a packed corpus, since
    unrenderable templates are dropped at pack time).
- If `flags` bit 0 is set, `a` -> `an` when the next word starts with `[aeiou]`.
- Spacing from the per-tag `attach` value: `1` glued to the previous word, `2`
  glued to the next word, `3` both, `0` space-separated.
- If `flags` bit 1 is set, capitalize the first ASCII lowercase letter (like
  `re.sub(..., count=1)`); the sentence is appended to `out` ending in its
  punctuation.

### Corpus contents

1,788 templates (1,794 minus the six treebank `LS` templates), 43 tags, 76,270
distinct strings, 71,431 universe words, 1,371,024 bytes, sha256
`2214d87d8aeb027c4c0e702213ed7d5e91e4816223d9b9e62918d769a4e6f72a`.

## src/page.rs

```rust
pub struct PageRenderer<'a> {
    corpus: &'a Corpus,
    rng: Rng,
    doc_root: String,       // normalized, may be "" for root or "/blog"
    path: String,           // normalized request path, e.g. "/blog/a-b"
    scratch: SentenceScratch, // reused across every sentence of the page
}

impl<'a> PageRenderer<'a> {
    pub fn new(corpus: &'a Corpus, seed: u64, doc_root: &str, path: &str) -> Self;
    pub fn render(&mut self, template: &str) -> String;
}
```

Seed: `Rng::new(fnv1a64(path.as_bytes()) ^ seed.wrapping_mul(0x9E3779B97F4A7C15))`.

### Text generation

- `get_word()` -> `rng.below(universe_len)` -> `universe_word(i)`.
- `get_sentence()` -> `generate_sentence_with` into a fresh `String` (used for
  `{SENTENCE}`).
- `get_header_into(out)` -> 1..=3 words, each capitalized first letter, joined
  by space, appended to `out`.
- `get_para_into(out)` -> 15..=20 sentences joined by space, appended to `out`.
- `get_title()` -> 1..=7 words joined by space, title-cased.
- `get_name()` -> two words, title-cased, joined by space.
- `get_main_html()` (port of Pyison `getMainHTML`):
  ```
  level = 1
  repeat rng.range_inc(3, 25) times:
      if rng.boolean():
          if rng.boolean() { level += 1 } else { level -= 1 }
          level = level.rem_euclid(4) + 1
      content += "<h{level}>"
      get_header_into(content)            // appended straight into content
      content += "</h{level}>\n<p>"
      get_para_into(para)                 // reused paragraph buffer
      add_links_into(para, content)
      content += "</p>\n"
  ```
- `add_links_into(text, out)`: split on space; 0..=3 times: `start =
  rng.usize(0, len)`, `end = min(start + rng.range_inc(0, 4) as usize, len - 1)`,
  then append the text to `out` with `<a href="{html_escape(get_link())}">`
  opened at `words[start]` and `</a>` closed after `words[end]`. The few words
  that carry a link boundary are written individually; the runs between them are
  copied in bulk. The RNG draw order (`usize`, `range_inc`, `get_link`) is
  unchanged.

### Path helpers (posixjoin semantics)

- `normalize_doc_root(s)`: trim; an empty or all-slash value becomes `""`;
  strip trailing `/`; add a leading `/` if missing (so `blog` -> `/blog`).
- `join(a, b)`: `a.trim_end_matches('/') + "/" + b.trim_start_matches('/')`,
  preserving a leading `/` when `a` is empty and `b` is relative (produce
  `/b`); if both empty -> `/`.
- `escape_page_name(title)`: replace `" "` with a random `SPACINGS` element,
  remove every `UNSAFE_CHARS` char, lowercase.
- `unescape_page_name(s)`: replace each spacer with a space.
- `page_title()`: if path is doc root / `/` -> `"Home"`; else title-case
  `unescape_page_name(basename(path))`.
- `parent_page_title()`: title-case `unescape_page_name(basename(dirname(path)))`,
  or `"Home"` when parent is the root.
- `parent_link()`: doc root path itself when at root, else `dirname(path)`.
- `get_path()`: `join(doc_root, gen_url())` where `gen_url` appends 1..=4 random
  words, removing unsafe chars.
- `get_page()`: `escape_page_name(get_title())`.
- `get_link()`: `join(get_path(), get_page())`.
- `get_sibling_link()`: `join(parent_link(), get_page())`.
- `get_link_for_title(t)`: `join(get_path(), escape_page_name(t))`.
- `get_sibling_for_title(t)`: `join(parent_link(), escape_page_name(t))`.
- `get_subpath(dir)`: `gen_url()` rooted at `join(doc_root_path(), dir)`.
- dirname/basename operate on `/`-separated paths; root is `/`.

### render(template)

Two passes. Pass 1 scans the template left to right and performs **every** RNG
draw in document order, storing the results (words/sentences/names and the
`{LINK}`/`{OVER}` slots with their resolved hrefs). Link hrefs may only be known
after the walk: each `{NEWTITLE}` pops the most recent pending slot (LIFO) and
binds it to `get_link_for_title(title)` for `LINK` or
`get_sibling_for_title(title)` for `OVER`; every slot left unbound is then
resolved in slot order with `get_link()` / `get_sibling_link()` (the old
post-walk RNG order). Static values are computed once and reused:
`{HOME}` = doc_root path (or `/`), `{TITLE}` = page_title, `{UPTITLE}` =
parent_page_title, `{UP}` = parent_link, `{MAIN}` = get_main_html(),
`{CSSLINK}` = get_subpath("css").

Pass 2 walks the template again and assembles the page in one preallocated
buffer, which removes the old full-size marker buffer and the substitution pass
that copied it:

- Static tags -> append the precomputed value, HTML-escaped where applicable
  (`{HOME}`, `{UP}`, `{MAIN}` and `{CSSLINK}` are emitted raw).
- `{WORD}` -> html_escape(get_word); `{SENTENCE}` -> html_escape(get_sentence);
  `{NAME}` -> html_escape(get_name); `{NEWTITLE}` -> html_escape(the title drawn
  in pass 1).
- `{PIC}` -> the URL drawn in pass 1, emitted raw (as before).
- `{LINK}` / `{OVER}` -> the resolved href.
- An unknown `{...}` tag is emitted verbatim.

This reproduces Pyison's behaviour where each `{NEWTITLE}` binds to the closest
preceding `{LINK}` or `{OVER}`, and `<a href="{LINK}">{NEWTITLE}</a>` ends up
with a matching URL and title.

`html_escape` replaces `&` -> `&amp;`, `<` -> `&lt;`, `>` -> `&gt;`,
`"` -> `&quot;` on dynamic text values only. Never escape the generated
`{MAIN}` HTML.

The returned page must contain no remaining `{` or `}` characters for the stock
template.

## src/assets.rs

```rust
/// Guess a content type from an extension name; unknown -> application/octet-stream.
pub fn content_type(ext: &str) -> String;

pub struct Assets { template: String, by_extension: HashMap<String, Bytes> }

impl Assets {
    pub fn from_dir(dir: &Path) -> Result<Assets, String>;
    pub fn template(&self) -> &str;
    pub fn by_extension(&self, ext: &str) -> Option<&Bytes>;
    pub fn extensions(&self) -> impl Iterator<Item = &str>;  // sorted
}
```

`from_dir` lists the directory, keeps regular files only, sorts them by name
(so errors and the chosen template are deterministic), and keys each file by its
lowercase extension only. The map stores bytes; nothing is keyed or filtered by
MIME type. An `html` file becomes the template (and is not served); every other
extension is accepted, with no `CONTENT_TYPES` allowlist. The `Content-Type` is
resolved at request time from the extension name with the `mime_guess` crate
(`content_type`), falling back to `application/octet-stream` when the extension
is unknown.

Startup errors: a missing or unreadable asset directory; a file with no
extension; a duplicate extension (message names both files); a directory without
an `html` file; a template that is not valid UTF-8. An unknown extension is not
an error. Nothing is embedded any more, so a deployed binary needs an assets
directory (or `--asset-dir`).

## src/app.rs

```rust
pub struct Config {
    pub host: String,
    pub port: u16,
    pub socket: Option<PathBuf>,
    pub seed: u64,
    pub doc_root: String,
    pub workers: usize,
    pub cache_size: usize,
    pub asset_dir: String,
    pub data_file: Option<PathBuf>,
}

pub struct App {
    pub corpus: Corpus,
    pub assets: Assets,
    pub config: Config,
    shards: Vec<Mutex<HashMap<String, Bytes>>>,
}

pub async fn handle(State(app): State<Arc<App>>, method: Method, uri: Uri) -> Response;
```

### Routing (fallback handler for every path)

1. Method not `GET`/`HEAD` -> `404` empty body.
2. `path = uri.path()`; `last_segment = path.rsplit('/').next()`.
3. If `last_segment` has a non-empty extension whose lowercase form is a loaded
   asset -> 200 with those bytes, `Content-Type` guessed from the extension name
   with `mime_guess` (`application/octet-stream` if unknown). There is no
   hard-coded `robots.txt` case; `txt` is a normal loaded extension.
4. Else if `last_segment` contains `.` -> `404` (unknown extension).
5. Else HTML: look up `path` in the cache; on hit return the stored bytes with
   `text/html; charset=utf-8`. On miss, render with a fresh `PageRenderer`
   seeded by `(seed, path)`, store in cache, return.

`HEAD` returns the same status, `Content-Type` and `Content-Length` as the
matching `GET`, with an empty body.

### Cache

- `cache_size` total entries, `0` disables caching.
- `SHARDS = 32`; per-shard capacity = `max(1, cache_size / SHARDS)`.
- Shard index = `fnv1a64(path) % SHARDS`.
- On insert when the shard is full and the key is absent, clear that shard first
  (cheap, keeps hot paths between clears, bounds memory).
- Store `Bytes` so cloning on hit is O(1) (an atomic refcount bump, no copy).

## src/main.rs

- Parse args, print usage on `--help` (also `-h`).
- `Assets::from_dir(config.asset_dir)`; on error print to stderr and exit 1.
- Build the corpus: `Corpus::from_file` for `--data-file`, else
  `Corpus::embedded()`; on error print to stderr and exit 1.
- Build `tokio::runtime::Builder::new_multi_thread()` with
  `worker_threads = if workers == 0 { available_parallelism() } else { workers }`,
  `enable_all()`, then `block_on` the serve future.
- If `--socket` is set, remove a stale socket file at that path and bind
  `UnixListener`, then best-effort chmod the socket to `0770` (a failed chmod is
  ignored); otherwise bind `TcpListener::bind((host, port))`. On failure print to
  stderr and exit 1.
- Log a single startup line with the TCP address or the unix socket path, seed,
  workers, cache size and the loaded asset extensions.
- `axum::serve(listener, Router::new().fallback(handle).with_state(app))`.

## Unit tests (in-module `#[cfg(test)]`, 32 total)

- `fnv1a64(b"") == 0xcbf29ce484222325`, `fnv1a64(b"hello")` known value.
- Two `Rng::new(42)` produce identical sequences; different seeds differ.
- `below(n) < n` for many draws; `choice` over one element returns it and over an
  empty slice returns `None`.
- `Corpus::embedded()` has 1,788 templates and 71,431 universe words; `CD` is the
  numeric tag with bounds 1..=100; both flags set; magic/version match.
- `generate_sentence` deterministic for a fixed seed; ends with `.`/`,`/`;`/`"`/`#`;
  starts uppercase; contains no `{` or `}`.
- Every template tag is renderable; 500 generated sentences never leak the raw
  tag `LS`.
- `a`/`an` agreement in a controlled fill; zeroing `flags` disables article fix
  and capitalization; `numberMin == numberMax == 7` yields the literal `7`.
- `Corpus::from_file` maps the on-disk corpus and matches the embedded one.
- Every word slice of the embedded corpus is valid UTF-8 (the invariant behind
  the `from_utf8_unchecked` in `Corpus::string`).
- Repeated access after load is not traversal-limited (20,000 accesses).
- Empty, truncated, mis-magic and non-message byte buffers are rejected without
  panicking.
- `PageRenderer` with the same `(seed, path)` renders identical HTML twice; a
  different path differs; output contains no leftover `{`.
- `{NEWTITLE}` binds to a preceding `{LINK}`.
- `escape_page_name` removes `'` and `` ` ``, replaces spaces with a spacer, and
  lowercases.
- `normalize_doc_root` / `join` semantics (`/`, `///`, `/blog/`, `blog`, ``).
- `asset_for` maps `.css`/`.ico`/`.jpg`/`.JPG`/`.png` to their guessed content
  types and rejects `x.`/`x`; shard index stays below `SHARDS`.
- `Assets::from_dir` loads the project assets (`css,ico,jpg,png,txt`), accepts an
  unknown extension (served as `application/octet-stream`), and rejects duplicate
  extensions, a missing `html`, and a file with no extension.
- `handle` serves `x.css`, `/robots.txt`, `y.png`, and 404s `q.gif`.

## Performance notes (must hold)

- No global lock on the hot path except the per-shard `Mutex` held only for a
  `HashMap` get/insert.
- No shared atomics on the read path. The corpus index is copied into owned
  `Vec`s at load and the `capnp::message::Reader` is dropped, so serving a page
  follows no Cap'n Proto pointer and never touches the shared `ReadLimiter`. The
  `capnp` `sync_reader` feature is **not** enabled.
- The `Corpus` index and word blob, `Assets` and the template are read-only and
  shared; word strings are zero-copy slices of the mmap/embedded bytes.
- Rendering is two-pass with preallocated, reused buffers: all RNG draws happen
  before any output is written, and sentences/paragraphs/links append into
  caller-owned `String`s (`SentenceScratch`, `get_*_into`, `add_links_into`).
  Pools are never copied, and link-free word runs are copied in bulk.
- Release profile uses LTO + 1 codegen unit.

Measured baseline (16 vCPU i7-11800H, loopback, release, `--seed 7`, uncached
`--cache-size 0`, random paths from `wrk -s /tmp/rand.lua`, `wrk -c 64` for 6 s;
per-page CPU = `utime + stime` from `/proc/PID/stat` divided by requests):

| workers | before req/s | before CPU/page | after req/s | after CPU/page |
|--------:|-------------:|----------------:|------------:|---------------:|
| 1       | 438          | 2.25 ms         | 3,314       | 0.29 ms        |
| 2       | 411          | 4.82 ms         | 6,381       | 0.30 ms        |
| 4       | 279          | 14.18 ms        | 12,268      | 0.31 ms        |
| 8       | 293          | 27.06 ms        | 22,759      | 0.34 ms        |
| 16      | 241          | 63.82 ms        | 33,775      | 0.42 ms        |

Before the rewrite, CPU per page grew with worker count while throughput stayed
flat (~250 req/s): the `sync_reader` `ReadLimiter` is an `AtomicUsize` and every
pointer follow did a load *and* a store on the same cache line, so workers
ping-ponged it. With the default cache, an `oha` matrix measured a cached page
at 45,630 req/s at concurrency 1 and 176,366 req/s at concurrency 64; the
uncached render path reached 31,962 req/s at c=64 and 24,031 req/s at c=4096.
