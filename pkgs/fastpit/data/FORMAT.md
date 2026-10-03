# Corpus format (`corpus.bin`)

`data/corpus.bin` is the runtime corpus. It is produced by
`python3 data/corpus.py pack` from `data/templates.json` +
`data/word_pools.json`, embedded into the server, and optionally memory-mapped
at runtime (`--data-file`).

It is a **standard Cap'n Proto message**. The schema is `data/corpus.capnp`;
that file is the authoritative field layout. The server walks the message
**once at load time**: it validates every field and copies the generation index
into owned tables, then drops the reader. The word blob stays a borrowed
**zero-copy** slice of the mapped/embedded bytes, so the request path has no
parsing pass, no `HashMap` and no per-word allocation.

The message holds **only corpus data**. It contains no HTML, no page template,
and no copy of the schema — the page template is an asset loaded from the asset
directory.

## Why Cap'n Proto

- **Zero copy where it matters.** At load the server wraps the bytes in
  `BufferSegments`, validates the message and copies the index (offsets, tag
  ids, pool ids, parameters) into owned `Vec`s, then drops the reader — a
  one-time cost, not a per-request one. Word strings are still read as `&str`
  slices of the mmap; nothing is deserialized.
- **Self-contained.** Words, tags, pools, templates, and the generation rules
  (numeric slot and bounds, per-tag spacing, article/capitalization flags) all
  live in the message. The server hardcodes no tag name or numeric range, so a
  different conforming `corpus.bin` changes the generated site with no
  recompilation.
- **Evolvable.** Cap'n Proto ignores unknown fields, so fields can be added
  without breaking older or newer readers. The `version` field and `magic`
  field let the server reject an unrelated file with a clear error instead of
  misreading it.
- **Cross-language.** The Python packer writes it with `pycapnp`; the Rust
  server reads it with the `capnp` crate, from the same schema.

## Message layout

`Corpus` fields (see `corpus.capnp` for types). The list lengths carry the
record counts, so there are no separate count fields:

| field | meaning |
|-------|---------|
| `magic` | `0x0054495054534146` (`b"FASTPIT\0"` little-endian) |
| `version` | payload version, currently `4` |
| `wordBlob` | concatenated UTF-8, no terminators |
| `wordOffsets` | `wordCount + 1` byte offsets into `wordBlob`, monotonic; `wordCount = len - 1` |
| `universeLen` | words `[0, universeLen)` are the word universe |
| `tagStrings` | `tagCount` word ids, one tag name each |
| `contentOff` | `tagCount + 1` cumulative offsets; tag `i`'s content pool is `contentItems[contentOff[i] .. contentOff[i+1]]` |
| `functionOff` | `tagCount + 1` cumulative offsets into `functionItems`, same convention |
| `punctString` | per-tag word id, or `0xFFFFFFFF` for none |
| `contentItems` / `functionItems` | word ids |
| `templateOff` | `templateCount + 1` cumulative offsets into `templateTags`; `templateCount = len - 1` |
| `templateTags` | tag ids |
| `numberTag` | tag id filled with a random integer, or `0xFFFFFFFF` |
| `numberMin` / `numberMax` | inclusive numeric-slot bounds |
| `flags` | bit 0: `a`→`an` before a vowel; bit 1: capitalize the first letter |
| `attach` | per tag: `0` space-separated, `1` attach left, `2` attach right, `3` both |

A zero-length pool is two equal consecutive offsets. `tagCount` is the common
length of `tagStrings`, `punctString`, and `attach`; it also equals
`len(contentOff) - 1` and `len(functionOff) - 1`.

## Ordering invariants

These preserve the exact generation order of the original JSON corpus, so
pages are byte-identical before and after the format change:

1. `wordBlob[0 .. universeLen]` is the word universe: every `content ∪
   function` word matching `^[a-z]+$` and length ≥ 2, deduplicated and
   **sorted**. The rest of the word table holds the remaining pool words and
   punctuation, deduplicated and sorted.
2. A content pool is `content[tag] ++ wordnet[tag]` for `NN`/`VB`/`JJ`/`RB`
   (unmerged for other tags); a function pool is `function[tag]` in source
   order. Pool sizes and orders are unchanged, so the RNG-to-word mapping is
   unchanged.
3. `tagStrings` is sorted by tag name.
4. `templateTags` preserves `templates.json` order, after dropping templates
   that contain a tag with no content/function pool and that is not the
   numeric tag (the six treebank `LS` templates).

## Reader validation

At load the server checks, and returns a descriptive error otherwise:

- `magic` and `version` match;
- the derived counts are consistent: `wordCount = len(wordOffsets) - 1`,
  `tagCount = len(tagStrings) = len(punctString) = len(attach) =
  len(contentOff) - 1 = len(functionOff) - 1`, and
  `templateCount = len(templateOff) - 1`;
- every offset array is non-decreasing, starts at 0, and ends at the length of
  the item list it indexes (`wordOffsets` → `wordBlob` bytes, `contentOff` →
  `contentItems`, `functionOff` → `functionItems`, `templateOff` →
  `templateTags`);
- every word range is valid UTF-8;
- every pool item is a valid word id;
- `universeLen <= wordCount`, `numberTag < tagCount` or absent,
  `numberMin <= numberMax`, every `attach` value in `0..=3`.

## Size

| piece | JSON | binary |
|-------|------|--------|
| templates (tags only; `example`/`count` dropped) | 502,247 B | ~63 KB |
| words + pools | 1,321,419 B | ~1.31 MB |
| total | 1,823,666 B | 1,371,024 B |

The win is at runtime: the JSON path builds `HashMap<String, Vec<String>>`
with ~76k heap strings; the Cap'n Proto path maps the file and copies its index
once at load, after which request handling allocates nothing for the corpus.

## Regenerating

From the repo root:

```
python3 data/corpus.py extract   # nltk treebank -> templates.json + word_pools.json
python3 data/corpus.py pack      # templates.json + word_pools.json -> corpus.bin
```

`extract` needs `nltk`; `pack` needs `pycapnp` (both from nixpkgs; see
`data/README.md` for the exact shells). Re-run
`pack` after any change to `data/templates.json`, `data/word_pools.json`, or
`data/corpus.capnp`, and recompile the server afterwards: the binary is
embedded by default (`--data-file` overrides it at runtime).
