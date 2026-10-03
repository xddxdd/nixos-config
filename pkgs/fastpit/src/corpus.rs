//! Corpus access and POS-template sentence generation.
//!
//! At runtime the corpus is a Cap'n Proto message (`data/corpus.capnp`)
//! embedded, memory-mapped or owned as a byte buffer. The message is only
//! traversed once at load time: `parse` validates it and copies every list
//! and scalar into plain immutable tables. The request path indexes those
//! tables directly and never touches a `capnp::message::Reader`, which would
//! otherwise hit the shared atomic read limiter on every pointer follow.
//! Word strings stay borrowed slices of the underlying buffer (zero-copy).

use std::fmt::Write as _;
use std::ops::Deref;
use std::path::Path;

use capnp::message::ReaderOptions;
use capnp::serialize::BufferSegments;

use crate::mmap::Mmap;
use crate::rng::Rng;

/// The generated schema code defines `pub mod corpus { .. }`, so it needs its
/// own wrapper module to avoid colliding with the `corpus` module itself.
pub mod schema {
    include!(concat!(env!("OUT_DIR"), "/corpus_capnp.rs"));
}

/// `b"FASTPIT\0"` little-endian.
const MAGIC: u64 = 0x0054_4950_5453_4146;
const VERSION: u32 = 4;
const ABSENT: u32 = 0xFFFF_FFFF;

pub enum CorpusBytes {
    Static(&'static [u8]),
    Mapped(Mmap),
    Owned(Vec<u8>),
}

impl Deref for CorpusBytes {
    type Target = [u8];

    fn deref(&self) -> &[u8] {
        match self {
            CorpusBytes::Static(bytes) => bytes,
            CorpusBytes::Mapped(map) => &map[..],
            CorpusBytes::Owned(bytes) => &bytes[..],
        }
    }
}

/// Plain immutable view of everything generation needs, copied out of the
/// Cap'n Proto message at load time. No pointer follows and no atomics remain.
struct Index {
    /// Absolute offset of the word blob inside the original buffer.
    word_blob_start: usize,
    word_blob_len: usize,
    word_offsets: Vec<u32>,
    universe_len: u32,
    tag_strings: Vec<u32>,
    content_off: Vec<u32>,
    function_off: Vec<u32>,
    punct_string: Vec<u32>,
    content_items: Vec<u32>,
    function_items: Vec<u32>,
    template_off: Vec<u32>,
    template_tags: Vec<u16>,
    number_tag: Option<u16>,
    number_min: i64,
    number_max: i64,
    flags: u32,
    attach: Vec<u8>,
}

pub struct Corpus {
    bytes: CorpusBytes,
    index: Index,
}

/// Reader options for load-time validation. The default 8M-word traversal
/// budget is cumulative and the whole message is walked once to copy the
/// index, so allow unlimited traversal; every field is bounds-checked here.
fn reader_options() -> ReaderOptions {
    let mut options = ReaderOptions::new();
    options.traversal_limit_in_words = None;
    options
}

impl Corpus {
    pub fn embedded() -> Corpus {
        Corpus::parse(CorpusBytes::Static(include_bytes!("../data/corpus.bin")))
            .expect("embedded corpus is valid")
    }

    pub fn from_file(path: &Path) -> Result<Corpus, String> {
        let map = Mmap::open(path).map_err(|e| format!("{}: {}", path.display(), e))?;
        Corpus::parse(CorpusBytes::Mapped(map))
    }

    #[allow(dead_code)]
    pub fn from_owned(bytes: Vec<u8>) -> Result<Corpus, String> {
        Corpus::parse(CorpusBytes::Owned(bytes))
    }

    fn parse(bytes: CorpusBytes) -> Result<Corpus, String> {
        // A corrupt or hostile file must never abort the process: Cap'n Proto
        // pointer traversal can panic on some malformed inputs even though the
        // API is `Result`-based, so contain it and report an error instead.
        match std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| Self::build(bytes))) {
            Ok(result) => result,
            Err(_) => Err("corpus is corrupt: validation panicked".to_string()),
        }
    }

    fn build(bytes: CorpusBytes) -> Result<Corpus, String> {
        let base = bytes.as_ptr() as usize;
        let options = reader_options();
        let segments = BufferSegments::new(bytes, options)
            .map_err(|e| format!("not a Cap'n Proto message: {}", e))?;
        let reader = capnp::message::Reader::new(segments, options);
        let index = {
            let root = reader
                .get_root()
                .map_err(|e| format!("cannot read corpus root: {}", e))?;
            validate(root, base)?
        };
        // Recover the byte buffer; the reader held no borrow beyond `validate`.
        let bytes = reader.into_segments().into_buffer();
        Ok(Corpus { bytes, index })
    }

    #[inline]
    fn word_blob(&self) -> &[u8] {
        let bytes: &[u8] = &self.bytes;
        &bytes[self.index.word_blob_start..self.index.word_blob_start + self.index.word_blob_len]
    }

    #[inline]
    pub fn string(&self, i: u32) -> &str {
        let offsets = &self.index.word_offsets;
        let start = offsets[i as usize] as usize;
        let end = offsets[i as usize + 1] as usize;
        // SAFETY: `validate` checked every word slice with `str::from_utf8`
        // at load time, and `word_offsets`/`word_blob` are immutable
        // afterwards, so this slice is guaranteed valid UTF-8.
        unsafe { core::str::from_utf8_unchecked(&self.word_blob()[start..end]) }
    }

    #[inline]
    pub fn universe_len(&self) -> u32 {
        self.index.universe_len
    }

    #[inline]
    pub fn universe_word(&self, i: u32) -> &str {
        self.string(i)
    }

    #[inline]
    pub fn number_tag(&self) -> Option<u16> {
        self.index.number_tag
    }

    #[inline]
    pub fn number_min(&self) -> i64 {
        self.index.number_min
    }

    #[inline]
    pub fn number_max(&self) -> i64 {
        self.index.number_max
    }

    #[inline]
    pub fn article_fix(&self) -> bool {
        self.index.flags & 0b01 != 0
    }

    #[inline]
    pub fn capitalize_first(&self) -> bool {
        self.index.flags & 0b10 != 0
    }

    /// Spacing mode for `tag` taken from the message: `0` space-separated,
    /// `1` attach to the previous word, `2` attach to the next word, `3` both.
    #[inline]
    pub fn attach(&self, tag: u16) -> u8 {
        self.index.attach[tag as usize]
    }

    #[allow(dead_code)]
    pub fn tag_count(&self) -> u32 {
        self.index.tag_strings.len() as u32
    }

    #[inline]
    pub fn tag_string(&self, t: u16) -> u32 {
        self.index.tag_strings[t as usize]
    }

    #[inline]
    #[allow(dead_code)]
    pub fn tag_name(&self, t: u16) -> &str {
        self.string(self.tag_string(t))
    }

    /// Tag `t`'s content pool is `contentItems[contentOff[t] .. contentOff[t+1]]`.
    #[inline]
    pub fn content_len(&self, t: u16) -> u32 {
        let off = &self.index.content_off;
        off[t as usize + 1] - off[t as usize]
    }

    #[inline]
    pub fn function_len(&self, t: u16) -> u32 {
        let off = &self.index.function_off;
        off[t as usize + 1] - off[t as usize]
    }

    #[inline]
    pub fn content_item(&self, t: u16, j: u32) -> u32 {
        let start = self.index.content_off[t as usize];
        self.index.content_items[(start + j) as usize]
    }

    #[inline]
    pub fn function_item(&self, t: u16, j: u32) -> u32 {
        let start = self.index.function_off[t as usize];
        self.index.function_items[(start + j) as usize]
    }

    #[inline]
    pub fn punct(&self, t: u16) -> Option<u32> {
        let value = self.index.punct_string[t as usize];
        if value == ABSENT {
            None
        } else {
            Some(value)
        }
    }

    #[inline]
    pub fn template_count(&self) -> u32 {
        self.index.template_off.len() as u32 - 1
    }

    #[inline]
    pub fn template_len(&self, t: u32) -> u32 {
        let off = &self.index.template_off;
        off[t as usize + 1] - off[t as usize]
    }

    #[inline]
    pub fn template_tag(&self, t: u32, k: u32) -> u16 {
        let start = self.index.template_off[t as usize];
        self.index.template_tags[(start + k) as usize]
    }
}

fn field<T>(value: capnp::Result<T>, what: &str) -> Result<T, String> {
    value.map_err(|e| format!("{}: {}", what, e))
}

/// Checks a cumulative offset array: non-empty, starts at 0, non-decreasing,
/// and its last element equals the length of the item list it indexes.
fn check_offsets(
    name: &str,
    len: u32,
    end: u32,
    get: impl Fn(u32) -> u32,
) -> Result<(), String> {
    if len == 0 {
        return Err(format!("{} is empty, expected at least one entry", name));
    }
    let mut prev = 0u32;
    for i in 0..len {
        let value = get(i);
        if i == 0 && value != 0 {
            return Err(format!("{} must start at 0", name));
        }
        if value < prev {
            return Err(format!("{} is not monotonic", name));
        }
        if value > end {
            return Err(format!("{} runs past the end of its item list", name));
        }
        prev = value;
    }
    if prev != end {
        return Err(format!(
            "{} ends at {}, item list has {} entries",
            name, prev, end
        ));
    }
    Ok(())
}

/// Validates the message and copies every field into an `Index`. `base` is the
/// address of the start of the buffer, used to turn the word blob's address
/// into an offset that stays valid once the buffer is re-owned by `Corpus`.
fn validate(root: schema::corpus::Reader<'_>, base: usize) -> Result<Index, String> {
    if root.get_magic() != MAGIC {
        return Err(format!(
            "bad magic 0x{:016x} (expected 0x{:016x})",
            root.get_magic(),
            MAGIC
        ));
    }
    let version = root.get_version();
    if version != VERSION {
        return Err(format!(
            "unsupported corpus version {} (this build reads version {})",
            version, VERSION
        ));
    }

    let word_blob = field(root.get_word_blob(), "wordBlob")?;
    let word_blob_start = word_blob.as_ptr() as usize - base;
    let word_blob_len = word_blob.len();
    let word_offsets: Vec<u32> = field(root.get_word_offsets(), "wordOffsets")?
        .iter()
        .collect();
    check_offsets(
        "wordOffsets",
        word_offsets.len() as u32,
        word_blob_len as u32,
        |i| word_offsets[i as usize],
    )?;
    let word_count = word_offsets.len() as u32 - 1;

    for i in 0..word_count {
        let start = word_offsets[i as usize] as usize;
        let end = word_offsets[i as usize + 1] as usize;
        if std::str::from_utf8(&word_blob[start..end]).is_err() {
            return Err(format!("word {} is not valid UTF-8", i));
        }
    }

    let universe_len = root.get_universe_len();
    if universe_len > word_count {
        return Err(format!(
            "universeLen {} exceeds wordCount {}",
            universe_len, word_count
        ));
    }

    let tag_strings: Vec<u32> = field(root.get_tag_strings(), "tagStrings")?.iter().collect();
    let tag_count = tag_strings.len() as u32;
    if tag_count > u16::MAX as u32 + 1 {
        return Err(format!("too many tags for u16 indices: {}", tag_count));
    }

    let content_off: Vec<u32> = field(root.get_content_off(), "contentOff")?.iter().collect();
    let function_off: Vec<u32> = field(root.get_function_off(), "functionOff")?
        .iter()
        .collect();
    let punct_string: Vec<u32> = field(root.get_punct_string(), "punctString")?
        .iter()
        .collect();
    let attach: Vec<u8> = field(root.get_attach(), "attach")?.iter().collect();
    for (name, len, expected) in [
        ("contentOff", content_off.len() as u32, tag_count + 1),
        ("functionOff", function_off.len() as u32, tag_count + 1),
        ("punctString", punct_string.len() as u32, tag_count),
        ("attach", attach.len() as u32, tag_count),
    ] {
        if len != expected {
            return Err(format!(
                "{} has {} entries, expected {}",
                name, len, expected
            ));
        }
    }

    for t in 0..tag_count {
        if tag_strings[t as usize] >= word_count {
            return Err(format!("tag {} has an out-of-range name id", t));
        }
    }
    for t in 0..tag_count {
        let punct = punct_string[t as usize];
        if punct != ABSENT && punct >= word_count {
            return Err(format!("punct string id for tag {} is out of range", t));
        }
    }

    let content_items: Vec<u32> = field(root.get_content_items(), "contentItems")?
        .iter()
        .collect();
    let function_items: Vec<u32> = field(root.get_function_items(), "functionItems")?
        .iter()
        .collect();
    check_offsets(
        "contentOff",
        content_off.len() as u32,
        content_items.len() as u32,
        |i| content_off[i as usize],
    )?;
    check_offsets(
        "functionOff",
        function_off.len() as u32,
        function_items.len() as u32,
        |i| function_off[i as usize],
    )?;

    for j in 0..content_items.len() {
        if content_items[j] >= word_count {
            return Err(format!("content item {} is an out-of-range word id", j));
        }
    }
    for j in 0..function_items.len() {
        if function_items[j] >= word_count {
            return Err(format!("function item {} is an out-of-range word id", j));
        }
    }

    let template_off: Vec<u32> = field(root.get_template_off(), "templateOff")?
        .iter()
        .collect();
    let template_tags: Vec<u16> = field(root.get_template_tags(), "templateTags")?
        .iter()
        .collect();
    check_offsets(
        "templateOff",
        template_off.len() as u32,
        template_tags.len() as u32,
        |i| template_off[i as usize],
    )?;
    for k in 0..template_tags.len() {
        if u32::from(template_tags[k]) >= tag_count {
            return Err(format!("template tag index {} is out of range", k));
        }
    }

    let number_raw = root.get_number_tag();
    let number_tag = if number_raw == ABSENT {
        None
    } else if number_raw < tag_count {
        Some(number_raw as u16)
    } else {
        return Err(format!("numberTag {} is out of range", number_raw));
    };

    let number_min = root.get_number_min();
    let number_max = root.get_number_max();
    if number_min > number_max {
        return Err(format!(
            "numberMin {} is greater than numberMax {}",
            number_min, number_max
        ));
    }

    for t in 0..tag_count {
        if attach[t as usize] > 3 {
            return Err(format!("attach value for tag {} is out of range", t));
        }
    }

    Ok(Index {
        word_blob_start,
        word_blob_len,
        word_offsets,
        universe_len,
        tag_strings,
        content_off,
        function_off,
        punct_string,
        content_items,
        function_items,
        template_off,
        template_tags,
        number_tag,
        number_min,
        number_max,
        flags: root.get_flags(),
        attach,
    })
}

#[inline]
fn starts_with_vowel(word: &str) -> bool {
    // The vowel set is ASCII, and a multi-byte UTF-8 lead byte can never equal
    // one of these, so inspecting the first byte is equivalent and avoids a
    // UTF-8 decode.
    matches!(word.as_bytes().first(), Some(b'a' | b'e' | b'i' | b'o' | b'u'))
}

/// A generated slot before it is written: a corpus string id, or a number
/// slot's value (formatted lazily into the scratch buffer). Keeping only the
/// id, rather than a `Cow<'_, str>`, lets the word list live across sentences
/// and removes the per-number `String` allocation.
enum Word {
    Str(u32),
    Number(i64),
}

/// Per-request scratch reused across every sentence of one page: the word list
/// (one heap allocation reused instead of one per sentence) and the number
/// formatting buffer. A paragraph holds 15..=20 sentences, a page up to 25
/// paragraphs, so this removes hundreds of allocations per page.
#[derive(Default)]
pub struct SentenceScratch {
    words: Vec<(u16, Word)>,
    number: String,
}

/// Convenience wrapper for the tests and callers with no scratch to reuse.
#[allow(dead_code)]
pub fn generate_sentence(rng: &mut Rng, corpus: &Corpus, out: &mut String) {
    let mut scratch = SentenceScratch::default();
    generate_sentence_with(rng, corpus, out, &mut scratch);
}

/// Fills one sentence into `out` (appended, so a paragraph builds in a single
/// buffer). `scratch` carries the word list between sentences. The RNG draw
/// order is unchanged: template draw, then one draw per slot, in order, and
/// all slots are drawn before any of them is written (so article agreement
/// still sees the untouched successor word).
pub fn generate_sentence_with(
    rng: &mut Rng,
    corpus: &Corpus,
    out: &mut String,
    scratch: &mut SentenceScratch,
) {
    let count = corpus.template_count();
    if count == 0 {
        return;
    }
    let t = rng.below(count as u64) as u32;
    let len = corpus.template_len(t);

    let SentenceScratch { words, number } = scratch;
    words.clear();
    words.reserve(len as usize);
    for k in 0..len {
        let tag = corpus.template_tag(t, k);
        let word = if corpus.number_tag() == Some(tag) {
            Word::Number(rng.range_inc(corpus.number_min(), corpus.number_max()))
        } else if let Some(string_id) = corpus.punct(tag) {
            Word::Str(string_id)
        } else if corpus.content_len(tag) > 0 {
            let j = rng.below(corpus.content_len(tag) as u64) as u32;
            Word::Str(corpus.content_item(tag, j))
        } else if corpus.function_len(tag) > 0 {
            let j = rng.below(corpus.function_len(tag) as u64) as u32;
            Word::Str(corpus.function_item(tag, j))
        } else {
            Word::Str(corpus.tag_string(tag))
        };
        words.push((tag, word));
    }

    let article_fix = corpus.article_fix();
    // Write directly into `out`. The leading separator space is skipped when
    // this is the sentence's first word (the old code pushed it and trimmed
    // the result); punctuation in the corpus is non-whitespace, so this is
    // byte-identical.
    let mut capitalized = !corpus.capitalize_first();
    let mut glue_next = false;
    let mut first = true;
    for i in 0..words.len() {
        let (tag, word) = &words[i];
        let mode = corpus.attach(*tag);
        let attached = mode == 1 || mode == 3 || glue_next;
        if !attached && !first {
            out.push(' ');
        }
        first = false;

        let mut w = match word {
            Word::Str(id) => corpus.string(*id),
            Word::Number(n) => {
                number.clear();
                write!(number, "{}", n).expect("write to string");
                number.as_str()
            }
        };
        // "a" becomes "an" before a vowel-initial follower. A number slot
        // starts with a digit, so only a corpus string can be a vowel-initial
        // successor.
        if article_fix && w == "a" {
            if let Some(Word::Str(next)) = words.get(i + 1).map(|(_, w)| w) {
                if starts_with_vowel(corpus.string(*next)) {
                    w = "an";
                }
            }
        }

        // Uppercase the first ASCII lowercase letter of the sentence in place,
        // preserving the old `capitalize_first_lower` semantics.
        let lower = if capitalized {
            None
        } else {
            w.bytes().position(|b| b.is_ascii_lowercase())
        };
        match lower {
            Some(rel) => {
                out.push_str(&w[..rel]);
                out.push((w.as_bytes()[rel] as char).to_ascii_uppercase());
                out.push_str(&w[rel + 1..]);
                capitalized = true;
            }
            None => out.extend(w.chars()),
        }
        glue_next = mode == 2 || mode == 3;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::page::PageRenderer;
    use std::collections::{BTreeSet, HashMap};

    const EMBEDDED_BYTES: &[u8] = include_bytes!("../data/corpus.bin");

    // Standard-corpus generation parameters; mirrors what data/corpus.py packs.
    const NUMBER_MIN: i64 = 1;
    const NUMBER_MAX: i64 = 100;
    const FLAGS: u32 = 0b11;

    const TINY_FUNCTION: &[(&str, &[&str])] = &[("DT", &["a"])];
    const TINY_CONTENT: &[(&str, &[&str])] = &[("NN", &["apple"])];
    const TINY_PUNCT: &[(&str, &str)] = &[(".", ".")];

    /// Spacing mode for the standard corpus's tag names (FORMAT.md invariant
    /// #6); the reader takes these values from the message itself.
    fn standard_attach(tag: &str) -> u8 {
        match tag {
            "." | "," | ";" | "-RRB-" | "''" | "POS" => 1,
            "-LRB-" | "``" | "$" => 2,
            "HYPH" => 3,
            _ => 0,
        }
    }

    /// Test-only Cap'n Proto writer, used to build small corpora with
    /// non-default generation parameters. Production only reads files packed
    /// by `data/corpus.py`.
    fn build_corpus(
        templates: &[&[&str]],
        function: &[(&str, &[&str])],
        content: &[(&str, &[&str])],
        punct: &[(&str, &str)],
        flags: u32,
        number_min: i64,
        number_max: i64,
    ) -> Vec<u8> {
        let mut tag_set: BTreeSet<String> = BTreeSet::new();
        tag_set.extend(function.iter().map(|(t, _)| t.to_string()));
        tag_set.extend(content.iter().map(|(t, _)| t.to_string()));
        tag_set.extend(punct.iter().map(|(t, _)| t.to_string()));
        for template in templates {
            tag_set.extend(template.iter().map(|t| t.to_string()));
        }
        tag_set.insert("CD".to_string());
        let tags: Vec<String> = tag_set.iter().cloned().collect();

        let content_map: HashMap<&str, &[&str]> = content.iter().copied().collect();
        let function_map: HashMap<&str, &[&str]> = function.iter().copied().collect();
        let punct_map: HashMap<&str, &str> = punct.iter().copied().collect();

        let mut universe_set: BTreeSet<String> = BTreeSet::new();
        for (_, words) in content.iter().chain(function.iter()) {
            for word in *words {
                if word.len() >= 2 && word.bytes().all(|b| b.is_ascii_lowercase()) {
                    universe_set.insert(word.to_string());
                }
            }
        }
        let universe: Vec<String> = universe_set.iter().cloned().collect();

        let mut referenced: BTreeSet<String> = tag_set.clone();
        for (_, words) in content.iter().chain(function.iter()) {
            referenced.extend(words.iter().map(|w| w.to_string()));
        }
        referenced.extend(punct.iter().map(|(_, p)| p.to_string()));

        let mut strings: Vec<String> = universe.clone();
        for word in &referenced {
            if !universe_set.contains(word) {
                strings.push(word.clone());
            }
        }

        let string_id: HashMap<&str, u32> = strings
            .iter()
            .enumerate()
            .map(|(i, s)| (s.as_str(), i as u32))
            .collect();
        let tag_index: HashMap<&str, u16> = tags
            .iter()
            .enumerate()
            .map(|(i, t)| (t.as_str(), i as u16))
            .collect();

        let mut blob: Vec<u8> = Vec::new();
        let mut word_offsets: Vec<u32> = Vec::with_capacity(strings.len() + 1);
        word_offsets.push(0);
        for s in &strings {
            blob.extend_from_slice(s.as_bytes());
            word_offsets.push(blob.len() as u32);
        }

        let tag_strings: Vec<u32> = tags.iter().map(|tag| string_id[tag.as_str()]).collect();

        let mut content_items: Vec<u32> = Vec::new();
        let mut function_items: Vec<u32> = Vec::new();
        let mut content_off: Vec<u32> = Vec::with_capacity(tags.len() + 1);
        let mut function_off: Vec<u32> = Vec::with_capacity(tags.len() + 1);
        let mut punct_string: Vec<u32> = Vec::with_capacity(tags.len());
        let mut attach: Vec<u8> = Vec::with_capacity(tags.len());
        content_off.push(0);
        function_off.push(0);
        for tag in &tags {
            if let Some(words) = content_map.get(tag.as_str()) {
                for word in *words {
                    content_items.push(string_id[*word]);
                }
            }
            content_off.push(content_items.len() as u32);

            if let Some(words) = function_map.get(tag.as_str()) {
                for word in *words {
                    function_items.push(string_id[*word]);
                }
            }
            function_off.push(function_items.len() as u32);

            punct_string.push(
                punct_map
                    .get(tag.as_str())
                    .map(|p| string_id[*p])
                    .unwrap_or(ABSENT),
            );
            attach.push(standard_attach(tag));
        }

        let mut template_tags: Vec<u16> = Vec::new();
        let mut template_off: Vec<u32> = Vec::with_capacity(templates.len() + 1);
        template_off.push(0);
        for template in templates {
            for tag in *template {
                template_tags.push(tag_index[*tag]);
            }
            template_off.push(template_tags.len() as u32);
        }

        let number_tag = tag_index.get("CD").copied().map(u32::from).unwrap_or(ABSENT);

        let mut message = capnp::message::Builder::new_default();
        {
            let mut root = message.init_root::<schema::corpus::Builder>();
            root.set_magic(MAGIC);
            root.set_version(VERSION);
            root.set_word_blob(&blob);
            root.set_word_offsets(&word_offsets[..]).unwrap();
            root.set_universe_len(universe.len() as u32);
            root.set_tag_strings(&tag_strings[..]).unwrap();
            root.set_content_off(&content_off[..]).unwrap();
            root.set_function_off(&function_off[..]).unwrap();
            root.set_punct_string(&punct_string[..]).unwrap();
            root.set_content_items(&content_items[..]).unwrap();
            root.set_function_items(&function_items[..]).unwrap();
            root.set_template_off(&template_off[..]).unwrap();
            root.set_template_tags(&template_tags[..]).unwrap();
            root.set_number_tag(number_tag);
            root.set_number_min(number_min);
            root.set_number_max(number_max);
            root.set_flags(flags);
            root.set_attach(&attach[..]).unwrap();
        }

        let mut out = Vec::new();
        capnp::serialize::write_message(&mut out, &message).unwrap();
        out
    }

    fn tiny_bytes(tags: &[&str]) -> Vec<u8> {
        build_corpus(
            &[tags],
            TINY_FUNCTION,
            TINY_CONTENT,
            TINY_PUNCT,
            FLAGS,
            NUMBER_MIN,
            NUMBER_MAX,
        )
    }

    fn tiny_corpus(tags: &[&str]) -> Corpus {
        Corpus::from_owned(tiny_bytes(tags)).unwrap()
    }

    fn with_raw_root<T>(bytes: &[u8], f: impl FnOnce(schema::corpus::Reader<'_>) -> T) -> T {
        let options = reader_options();
        let segments = BufferSegments::new(bytes, options).unwrap();
        let reader = capnp::message::Reader::new(segments, options);
        f(reader.get_root().unwrap())
    }

    /// Builds one sentence as a String for the tests that predate the
    /// append-into-buffer API.
    fn sentence(rng: &mut Rng, corpus: &Corpus) -> String {
        let mut out = String::new();
        generate_sentence(rng, corpus, &mut out);
        out
    }

    #[test]
    fn every_word_is_valid_utf8() {
        // The request path reads words with `from_utf8_unchecked`; this proves
        // the load-time check actually covered every word slice.
        let corpus = Corpus::embedded();
        let offsets = &corpus.index.word_offsets;
        let blob = corpus.word_blob();
        for i in 0..offsets.len() - 1 {
            let start = offsets[i] as usize;
            let end = offsets[i + 1] as usize;
            assert!(
                std::str::from_utf8(&blob[start..end]).is_ok(),
                "word {} is not valid UTF-8",
                i
            );
        }
    }

    #[test]
    fn embedded_has_data() {
        let corpus = Corpus::embedded();
        assert_eq!(corpus.template_count(), 1788);
        assert_eq!(corpus.universe_len(), 71431);
        assert!(corpus.tag_count() > 0);
        assert_eq!(corpus.tag_name(corpus.number_tag().unwrap()), "CD");
        assert_eq!(corpus.number_min(), 1);
        assert_eq!(corpus.number_max(), 100);
        assert!(corpus.article_fix());
        assert!(corpus.capitalize_first());

        with_raw_root(EMBEDDED_BYTES, |root| {
            assert_eq!(root.get_magic(), MAGIC);
            assert_eq!(root.get_version(), VERSION);
        });
    }

    #[test]
    fn sentence_is_deterministic() {
        let corpus = Corpus::embedded();
        let mut a = Rng::new(123);
        let mut b = Rng::new(123);
        assert_eq!(sentence(&mut a, &corpus), sentence(&mut b, &corpus));
    }

    #[test]
    fn sentence_shape() {
        let corpus = Corpus::embedded();
        let mut rng = Rng::new(2024);
        for _ in 0..200 {
            let s = sentence(&mut rng, &corpus);
            assert!(!s.is_empty());
            assert!(!s.contains('{'));
            assert!(!s.contains('}'));
            let end = s.chars().last().unwrap();
            assert!(
                matches!(end, '.' | ',' | ';' | '"' | '#'),
                "unexpected ending {:?} in {:?}",
                end,
                s
            );
            let first_alpha = s.chars().find(|c| c.is_alphabetic()).unwrap();
            assert!(
                first_alpha.is_uppercase(),
                "sentence not capitalized: {:?}",
                s
            );
        }
    }

    #[test]
    fn article_agreement() {
        let corpus = tiny_corpus(&["DT", "NN"]);
        let mut rng = Rng::new(1);
        assert_eq!(sentence(&mut rng, &corpus), "An apple");
    }

    #[test]
    fn templates_are_all_renderable() {
        let corpus = Corpus::embedded();
        for t in 0..corpus.template_count() {
            for k in 0..corpus.template_len(t) {
                let tag = corpus.template_tag(t, k);
                assert!(
                    corpus.number_tag() == Some(tag)
                        || corpus.punct(tag).is_some()
                        || corpus.content_len(tag) > 0
                        || corpus.function_len(tag) > 0,
                    "unrenderable tag {:?}",
                    corpus.tag_name(tag)
                );
            }
        }
    }

    #[test]
    fn sentences_never_leak_raw_tags() {
        let corpus = Corpus::embedded();
        let mut rng = Rng::new(99);
        for _ in 0..500 {
            let sentence = sentence(&mut rng, &corpus);
            assert!(
                !sentence.split_whitespace().any(|w| w == "LS"),
                "raw tag leaked: {:?}",
                sentence
            );
            assert!(!sentence.contains('{') && !sentence.contains('}'));
        }
    }

    #[test]
    fn owned_corpus_matches_embedded() {
        // from_owned must stay equivalent to the embedded byte slice.
        let embedded = Corpus::embedded();
        let owned = Corpus::from_owned(EMBEDDED_BYTES.to_vec()).unwrap();
        let assets = crate::assets::Assets::from_dir(std::path::Path::new("assets")).unwrap();
        for path in ["/", "/a/b", "/blog/post", "/x/y/z", "/index.html"] {
            let mut a = PageRenderer::new(&embedded, 7, "/", path);
            let mut b = PageRenderer::new(&owned, 7, "/", path);
            assert_eq!(
                a.render(assets.template()),
                b.render(assets.template()),
                "path {}",
                path
            );
        }
    }

    #[test]
    fn corpus_has_no_template_content() {
        // The page template lives in assets/, never inside corpus.bin.
        for needle in ["{MAIN}", "<!DOCTYPE", "<!doctype", "<html", "<title>"] {
            assert!(
                !EMBEDDED_BYTES
                    .windows(needle.len())
                    .any(|window| window == needle.as_bytes()),
                "corpus contains template content {:?}",
                needle
            );
        }
    }

    #[test]
    fn params_flags_control_generation() {
        let corpus = tiny_corpus(&["DT", "NN"]);
        let mut rng = Rng::new(1);
        assert_eq!(sentence(&mut rng, &corpus), "An apple");

        // Zero the flags: article fix and capitalization must switch off,
        // proving the reader takes them from the file ("a apple", not "An apple").
        let bytes = build_corpus(
            &[&["DT", "NN"]],
            TINY_FUNCTION,
            TINY_CONTENT,
            TINY_PUNCT,
            0,
            NUMBER_MIN,
            NUMBER_MAX,
        );
        let corpus = Corpus::from_owned(bytes).unwrap();
        let mut rng = Rng::new(1);
        assert_eq!(sentence(&mut rng, &corpus), "a apple");
    }

    #[test]
    fn params_number_range_controls_generation() {
        let bytes = tiny_bytes(&["CD"]);
        with_raw_root(&bytes, |root| {
            assert_eq!(root.get_number_min(), NUMBER_MIN);
            assert_eq!(root.get_number_max(), NUMBER_MAX);
        });

        let bytes = build_corpus(
            &[&["DT", "NN"]],
            TINY_FUNCTION,
            TINY_CONTENT,
            TINY_PUNCT,
            FLAGS,
            7,
            7,
        );
        let corpus = Corpus::from_owned(bytes).unwrap();
        assert_eq!(corpus.number_min(), 7);
        assert_eq!(corpus.number_max(), 7);

        // With numberMin == numberMax == 7 the numeric slot is literally "7".
        let bytes = build_corpus(
            &[&["CD"]],
            TINY_FUNCTION,
            TINY_CONTENT,
            TINY_PUNCT,
            FLAGS,
            7,
            7,
        );
        let corpus = Corpus::from_owned(bytes).unwrap();
        let mut rng = Rng::new(1);
        assert_eq!(sentence(&mut rng, &corpus), "7");
    }

    #[test]
    fn from_file_maps_corpus() {
        let corpus = Corpus::from_file(Path::new("data/corpus.bin")).unwrap();
        assert_eq!(corpus.template_count(), 1788);
        assert_eq!(corpus.universe_len(), 71431);

        let embedded = Corpus::embedded();
        let assets = crate::assets::Assets::from_dir(std::path::Path::new("assets")).unwrap();
        for path in ["/", "/a/b", "/long/path/here"] {
            let mut mapped = PageRenderer::new(&corpus, 7, "/", path);
            let mut embedded_render = PageRenderer::new(&embedded, 7, "/", path);
            assert_eq!(
                mapped.render(assets.template()),
                embedded_render.render(assets.template())
            );
        }
    }

    #[test]
    fn repeated_access_is_not_traversal_limited() {
        // Repeated access reads the copied index, not a cumulative-limit reader,
        // so many accesses after load must all succeed.
        let corpus = Corpus::embedded();
        let mut rng = Rng::new(5);
        for _ in 0..20_000 {
            assert!(!corpus.string(0).is_empty());
            let _ = sentence(&mut rng, &corpus);
        }
    }

    #[test]
    fn corrupt_corpus_is_rejected_not_panicked() {
        assert!(Corpus::from_owned(Vec::new()).is_err());
        assert!(Corpus::from_owned(vec![0u8; 16]).is_err());
        assert!(Corpus::from_owned(b"not a capnp message".to_vec()).is_err());

        let mut bad_magic = EMBEDDED_BYTES.to_vec();
        let word = &bad_magic[8..16];
        let word = u64::from_le_bytes(word.try_into().unwrap()) ^ 0xff;
        bad_magic[8..16].copy_from_slice(&word.to_le_bytes());
        assert!(Corpus::from_owned(bad_magic).is_err());
    }
}
