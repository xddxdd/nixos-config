# `data/` — corpus and data pipeline

This directory holds the offline corpus for fastpit, the single tool that
builds it, and the format spec. Nothing here is needed at server runtime: the
packed artifact is embedded into the binary, or memory-mapped via
`--data-file`.

| file | role |
|------|------|
| `templates.json` | source POS-tag sentence templates (input to packing) |
| `word_pools.json` | source word pools (input to packing) |
| `corpus.capnp` | Cap'n Proto schema for `corpus.bin` (authoritative layout) |
| `corpus.bin` | packed runtime corpus, embedded at compile time |
| `corpus.py` | the whole pipeline: `extract`, `pack`, `all`, `generate` |
| `FORMAT.md` | format spec for `corpus.bin` |

Every default path is resolved relative to `corpus.py` itself, so the commands
work when invoked as `python3 data/corpus.py …` from the repo root or from
anywhere else.

## `corpus.py`

One script, four subcommands:

```
python3 data/corpus.py <command> [options]
```

| command | effect |
|---------|--------|
| `extract` | mine templates + pools from the nltk treebank → `templates.json` + `word_pools.json` |
| `pack` | pack those two JSON files into the Cap'n Proto `corpus.bin` |
| `all` | `extract` then `pack` |
| `generate` | print sample sentences from the JSON (Python reference generator) |

| option | default | meaning |
|--------|---------|---------|
| `--templates PATH` | `<script dir>/templates.json` | template JSON |
| `--pools PATH` | `<script dir>/word_pools.json` | pool JSON |
| `--out PATH` | `<script dir>/corpus.bin` | packed output |
| `--schema PATH` | `<script dir>/corpus.capnp` | Cap'n Proto schema used by `pack` |
| `-n`, `--count N` | `10` | `generate`: number of sentences |
| `--seed N` | `0` | `generate`: RNG seed |
| `-h`, `--help` | | print usage, exit 0 |

Heavy imports are lazy: `nltk` is imported only by `extract`, `pycapnp` only by
`pack`, so `generate` runs with neither installed. No command, an unknown
command, or a malformed option prints the usage on stderr and exits 2.

## Pipeline

```
nltk treebank parses
        │  corpus.py extract: drop trace tokens, keep 4–22-token sentences
        │  ending in ".", no "-RRB-"; count unique POS-tag sequences
        ▼
data/templates.json  (1,794 unique POS sequences, sorted by frequency)

treebank words ──► function pools (top 20 per tag) + content pools (per inflected tag)
names corpus ────► NNP pool (treebank proper nouns are junk: tickers, "j.l.")
WordNet ─────────► base-form NN/VB/JJ/RB pools
        ▼
data/word_pools.json  (function / content / punct / wordnet pools)
        │
        │  corpus.py pack  (Cap'n Proto, schema corpus.capnp)
        ▼
data/corpus.bin  (runtime corpus: embedded, or mmap'd via --data-file)
```

`extract` produces the two JSON files. `pack` only restructures them into an
indexed, zero-copy binary — it never generates sentences. `generate` is the
Python reference implementation of sentence generation, matching
`src/corpus.rs` (`generate_sentence`).

## `templates.json`

An array sorted by descending frequency. Each element:

```json
{"tags": ["NN", "VBD", "RB", "VBN", "."], "count": 8, "example": "Terms were n't disclosed ."}
```

- `tags` — a treebank POS sequence; each tag is a slot to be filled at
  generation time.
- `count` — how many treebank sentences had this sequence (unused at runtime;
  dropped by packing).
- `example` — the original treebank sentence, kept for provenance (unused at
  runtime; dropped by packing).

## `word_pools.json`

An object with four sections:

- `function` — tag → up to 20 function words (determiners, prepositions,
  pronouns, …); 16 tags.
- `content` — tag → inflected content words from treebank; 16 tags. Verb
  inflections (`VBD`/`VBG`/`VBN`/`VBP`/`VBZ`) are separate pools so the verb
  form matches the template slot. `CD` is absent — numbers are generated
  randomly at fill time.
- `punct` — 10 punctuation tags → literal character (`-LRB-` → `(`, `HYPH` →
  `-`, …).
- `wordnet` — base-form WordNet lists keyed by base POS (`NN`, `VB`, `JJ`,
  `RB`), used to add variety to those slots.

At pack time the `wordnet` base-form pools are **merged into `content`** for
`NN`/`VB`/`JJ`/`RB`: the packed content pool for such a tag is
`content[tag] ++ wordnet[tag]` (source order first, WordNet appended). The JSON
files on disk stay separate; only `corpus.bin` carries the merged form.

## `corpus.bin`

The packed runtime artifact, produced by `python3 data/corpus.py pack` from
`templates.json` + `word_pools.json`. It is the form embedded into the server
and the form `--data-file` memory-maps. It is a **standard Cap'n Proto
message**; the schema `corpus.capnp` is the authoritative field layout, and
[`FORMAT.md`](FORMAT.md) documents it.

The format exists for **O(1) indexed access and zero-copy word reads**: the
server maps the file, validates the message once at load and copies the index
(`u32`/`u16` offsets and ids) into owned tables, then drops the reader. Word
strings stay borrowed `&str` slices of the mapping. There is no parsing pass,
no `HashMap`, and no per-word allocation on the request path.

It drops the unused `count`/`example` template fields, collapses every word
into one string table, and carries the record counts in the offset arrays
rather than as separate fields. That shrinks templates from ~502 KB to ~63 KB
and the total corpus from ~1.82 MB (1,823,666 B of JSON) to ~1.37 MB
(1,371,024 B). The packed corpus holds:

| count | value |
|-------|-------|
| templates | 1,788 (the 6 treebank `LS` templates are dropped) |
| distinct tags | 43 |
| distinct strings | 76,270 |
| universe words | 71,431 |
| content items | 85,555 |
| function items | 114 |

Ordering is fixed, so generation is fully deterministic: the word universe is
deduplicated and sorted, a content pool stays `content[tag] ++ wordnet[tag]`
for `NN`/`VB`/`JJ`/`RB`, tag names are sorted, and templates keep
`templates.json` order.

The message is **self-contained**: words, tags, pools, templates, and the
generation rules (numeric slot and bounds, per-tag spacing,
article/capitalization flags) all live in it. It holds only corpus data — no
HTML and no page template. The server hardcodes no tag name, so a different
conforming `corpus.bin` changes the generated site without recompiling.

sha256 of `corpus.bin` as of this commit:

```
2214d87d8aeb027c4c0e702213ed7d5e91e4816223d9b9e62918d769a4e6f72a
```

## Regenerating

Run from the repo root.

`extract` needs nltk (NixOS):

```
nix-shell -p python313Packages.nltk
python3 -c "import nltk; [nltk.download(p) for p in ('treebank', 'wordnet', 'names')]"
python3 data/corpus.py extract
```

`pack` needs `pycapnp` (NixOS):

```
nix-shell -p python313Packages.pycapnp --run 'python3 data/corpus.py pack'
```

Or both at once, with the environment already set up:

```
python3 data/corpus.py all
```

`pack` accepts `--templates`, `--pools`, `--out` and `--schema` to override the
paths; the defaults point next to the script.

**`data/corpus.bin` must be repacked after every change to
`data/templates.json`, `data/word_pools.json`, or `data/corpus.capnp`**, and a
release build must be recompiled afterwards, because the runtime embeds the
binary at compile time. `--data-file <corpus.bin>` overrides the embedded copy
at runtime.

## Generating sentences

`python3 data/corpus.py generate` picks a template at random, fills each slot
from the matching pool, fixes a/an vowel agreement, assembles spacing per
punctuation tag, and capitalizes the sentence. It prints 10 sentences; use
`-n` and `--seed` to change the count and seed:

```
python3 data/corpus.py generate -n 20 --seed 42
```
