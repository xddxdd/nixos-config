//! Path/title/link generation and HTML tag substitution (port of Pyison's
//! `wrapper.getHtml` plus `Generator` page helpers).

use std::fmt::Write as _;

use crate::corpus::{generate_sentence_with, Corpus, SentenceScratch};
use crate::rng::{fnv1a64, Rng};

const SEED_MIX: u64 = 0x9e37_79b9_7f4a_7c15;

/// Page-name spacers, tried in this order by `escape_page_name`. Constant, so
/// no per-request allocation happens.
const SPACINGS: &[&str] = &["_", "-", "%20"];
/// Characters stripped from generated page names and URLs.
const UNSAFE_CHARS: &[char] = &['\'', '`'];

#[derive(Clone, Copy, PartialEq, Eq)]
enum Kind {
    Link,
    Over,
}

#[derive(Clone, Copy)]
struct Slot {
    kind: Kind,
}

pub struct PageRenderer<'a> {
    corpus: &'a Corpus,
    rng: Rng,
    doc_root: String,
    path: String,
    /// Reused word list / number buffer for every sentence of the page.
    scratch: SentenceScratch,
}

pub fn normalize_doc_root(s: &str) -> String {
    let mut trimmed = s.trim();
    if trimmed.is_empty() {
        return String::new();
    }
    trimmed = trimmed.trim_end_matches('/');
    if trimmed.is_empty() {
        return String::new();
    }
    // Accept `blog` as well as `/blog`, so links always stay absolute.
    if trimmed.starts_with('/') {
        trimmed.to_string()
    } else {
        format!("/{}", trimmed)
    }
}

pub fn join(a: &str, b: &str) -> String {
    format!("{}/{}", a.trim_end_matches('/'), b.trim_start_matches('/'))
}

fn dirname(path: &str) -> String {
    if path.is_empty() {
        return String::new();
    }
    match path.rfind('/') {
        None => String::new(),
        Some(0) => "/".to_string(),
        Some(i) => path[..i].to_string(),
    }
}

fn basename(path: &str) -> String {
    match path.rfind('/') {
        None => path.to_string(),
        Some(i) => path[i + 1..].to_string(),
    }
}

/// Appends `word` with its first character uppercased, matching the old
/// `capitalize_word(..) +` allocation.
#[inline]
fn push_capitalized(out: &mut String, word: &str) {
    let mut chars = word.chars();
    if let Some(first) = chars.next() {
        for c in first.to_uppercase() {
            out.push(c);
        }
        out.push_str(chars.as_str());
    }
}

/// Appends `word` in title case: the first alphabetic run starts uppercased,
/// every later alphabetic run is lowercased. Non-alphabetic characters reset
/// the "previous was cased" state. Writes straight into `out`.
#[inline]
fn push_title_case(out: &mut String, word: &str) {
    let mut prev_cased = false;
    for c in word.chars() {
        if c.is_alphabetic() {
            if prev_cased {
                for lc in c.to_lowercase() {
                    out.push(lc);
                }
            } else {
                for uc in c.to_uppercase() {
                    out.push(uc);
                }
            }
            prev_cased = true;
        } else {
            out.push(c);
            prev_cased = false;
        }
    }
}

fn title_case(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    push_title_case(&mut out, s);
    out
}

/// Appends `s` with `& < > "` escaped, in one pass (no chained `str::replace`).
#[inline]
fn push_html_escaped(out: &mut String, s: &str) {
    for c in s.chars() {
        match c {
            '&' => out.push_str("&amp;"),
            '<' => out.push_str("&lt;"),
            '>' => out.push_str("&gt;"),
            '"' => out.push_str("&quot;"),
            _ => out.push(c),
        }
    }
}

/// Appends `s` with every `UNSAFE_CHARS` character removed.
#[inline]
fn push_without_unsafe(out: &mut String, s: &str) {
    for c in s.chars() {
        if !UNSAFE_CHARS.contains(&c) {
            out.push(c);
        }
    }
}

impl<'a> PageRenderer<'a> {
    pub fn new(corpus: &'a Corpus, seed: u64, doc_root: &str, path: &str) -> Self {
        let rng = Rng::new(fnv1a64(path.as_bytes()) ^ seed.wrapping_mul(SEED_MIX));
        PageRenderer {
            corpus,
            rng,
            doc_root: normalize_doc_root(doc_root),
            path: path.to_string(),
            scratch: SentenceScratch::default(),
        }
    }

    /// Borrows the chosen word straight out of the corpus (`&'a str`), so no
    /// per-word allocation happens. Draws exactly one `rng.below(count)` and
    /// returns `""` without drawing when the universe is empty.
    pub fn get_word(&mut self) -> &'a str {
        let corpus = self.corpus;
        let count = corpus.universe_len();
        if count == 0 {
            return "";
        }
        let i = self.rng.below(count as u64) as u32;
        corpus.universe_word(i)
    }

    pub fn get_sentence(&mut self) -> String {
        let mut out = String::with_capacity(256);
        generate_sentence_with(&mut self.rng, self.corpus, &mut out, &mut self.scratch);
        out
    }

    fn get_header_into(&mut self, out: &mut String) {
        let n = self.rng.range_inc(1, 3);
        for i in 0..n {
            if i > 0 {
                out.push(' ');
            }
            let word = self.get_word();
            push_capitalized(out, word);
        }
    }

    fn get_para_into(&mut self, out: &mut String) {
        out.clear();
        let n = self.rng.range_inc(15, 20);
        let corpus = self.corpus;
        for i in 0..n {
            if i > 0 {
                out.push(' ');
            }
            generate_sentence_with(&mut self.rng, corpus, out, &mut self.scratch);
        }
    }

    pub fn get_title(&mut self) -> String {
        let n = self.rng.range_inc(1, 7);
        let mut out = String::with_capacity(128);
        for i in 0..n {
            if i > 0 {
                out.push(' ');
            }
            let word = self.get_word();
            push_title_case(&mut out, word);
        }
        out
    }

    pub fn get_name(&mut self) -> String {
        let mut out = String::with_capacity(48);
        let first = self.get_word();
        push_title_case(&mut out, first);
        out.push(' ');
        let last = self.get_word();
        push_title_case(&mut out, last);
        out
    }

    pub fn get_main_html(&mut self) -> String {
        let mut level: i64 = 1;
        let mut content = String::with_capacity(64 * 1024);
        // The paragraph is the only scratch buffer: the header and the
        // link-decorated paragraph are appended straight into `content`, so a
        // section's text is copied twice (into `para`, then into `content`)
        // instead of three times.
        let mut para = String::with_capacity(16 * 1024);
        let n = self.rng.range_inc(3, 25);
        for _ in 0..n {
            if self.rng.boolean() {
                if self.rng.boolean() {
                    level += 1;
                } else {
                    level -= 1;
                }
                level = level.rem_euclid(4) + 1;
            }
            write!(content, "<h{0}>", level).expect("write to string");
            self.get_header_into(&mut content);
            write!(content, "</h{0}>\n<p>", level).expect("write to string");
            self.get_para_into(&mut para);
            self.add_links_into(&para, &mut content);
            content.push_str("</p>\n");
        }
        content
    }

    fn add_links_into(&mut self, text: &str, out: &mut String) {
        let word_count = text.matches(' ').count() + 1;
        if word_count == 0 {
            return;
        }
        let times = self.rng.range_inc(0, 3);
        // Draw order (usize, range_inc, get_link) must match the old loop.
        let mut links: Vec<(usize, usize, String)> = Vec::with_capacity(times as usize);
        for _ in 0..times {
            let start = self.rng.usize(0, word_count);
            let end = (start + self.rng.range_inc(0, 4) as usize).min(word_count - 1);
            let link = self.get_link();
            links.push((start, end, link));
        }

        // One pass over the words, but only the few words that carry an open
        // or a close are written individually; the runs between boundaries are
        // copied in bulk. Applying the opens in reverse link order and the
        // closes in forward order reproduces the old sequential
        // `words[start] = wrap(words[start]); words[end] += "</a>"`.
        out.reserve(text.len() + 48 * links.len());
        if links.is_empty() {
            out.push_str(text);
            return;
        }
        let base = text.as_ptr() as usize;
        let mut cursor = 0usize;
        for (k, word) in text.split(' ').enumerate() {
            let has_open = links.iter().any(|(s, _, _)| *s == k);
            let has_close = links.iter().any(|(_, e, _)| *e == k);
            if !has_open && !has_close {
                continue;
            }
            let word_start = word.as_ptr() as usize - base;
            out.push_str(&text[cursor..word_start]);
            cursor = word_start + word.len();
            for (s, _, href) in links.iter().rev() {
                if *s == k {
                    out.push_str("<a href=\"");
                    push_html_escaped(out, href);
                    out.push_str("\">");
                }
            }
            out.push_str(word);
            for (_, e, _) in links.iter() {
                if *e == k {
                    out.push_str("</a>");
                }
            }
        }
        out.push_str(&text[cursor..]);
    }

    pub fn escape_page_name(&mut self, title: &str) -> String {
        let spacer = self.rng.choice(SPACINGS).copied().unwrap_or("_");
        let mut out = String::with_capacity(title.len() + 16);
        for c in title.chars() {
            if c == ' ' {
                out.push_str(spacer);
            } else if !UNSAFE_CHARS.contains(&c) {
                // Titles here come from the `^[a-z]+$` word universe (possibly
                // title-cased), so ASCII lowercasing is identical to Unicode
                // lowercasing and needs no second pass.
                out.push(c.to_ascii_lowercase());
            }
        }
        out
    }

    pub fn unescape_page_name(&self, s: &str) -> String {
        let mut out = String::with_capacity(s.len());
        let mut rest = s;
        while !rest.is_empty() {
            if let Some(stripped) = rest.strip_prefix("%20") {
                out.push(' ');
                rest = stripped;
            } else if let Some(stripped) = rest.strip_prefix('_') {
                out.push(' ');
                rest = stripped;
            } else if let Some(stripped) = rest.strip_prefix('-') {
                out.push(' ');
                rest = stripped;
            } else {
                let c = rest.chars().next().expect("rest is non-empty");
                out.push(c);
                rest = &rest[c.len_utf8()..];
            }
        }
        out
    }

    fn doc_root_path(&self) -> String {
        if self.doc_root.is_empty() {
            "/".to_string()
        } else {
            self.doc_root.clone()
        }
    }

    fn is_doc_root(&self) -> bool {
        let trimmed = if self.path.len() > 1 {
            self.path.trim_end_matches('/')
        } else {
            self.path.as_str()
        };
        if self.doc_root.is_empty() {
            trimmed == "/" || trimmed.is_empty()
        } else {
            trimmed == self.doc_root
        }
    }

    pub fn page_title(&self) -> String {
        if self.is_doc_root() {
            "Home".to_string()
        } else {
            title_case(&self.unescape_page_name(&basename(&self.path)))
        }
    }

    pub fn parent_page_title(&self) -> String {
        let parent = dirname(&self.path);
        let unescaped = self.unescape_page_name(&basename(&parent));
        if unescaped.is_empty() {
            "Home".to_string()
        } else {
            title_case(&unescaped)
        }
    }

    pub fn parent_link(&self) -> String {
        if self.is_doc_root() {
            self.doc_root_path()
        } else {
            dirname(&self.path)
        }
    }

    fn gen_url(&mut self) -> String {
        let n = self.rng.range_inc(1, 4);
        let mut url = String::with_capacity(64);
        for _ in 0..n {
            let word = self.get_word();
            // In-place `join(&url, &word)`: trim the old trailing slashes, add
            // one separator, then the word without its leading slashes.
            if url.is_empty() {
                url.push('/');
            } else {
                while url.ends_with('/') {
                    url.pop();
                }
                url.push('/');
            }
            push_without_unsafe(&mut url, word.trim_start_matches('/'));
        }
        url
    }

    pub fn get_path(&mut self) -> String {
        let generated = self.gen_url();
        join(&self.doc_root, &generated)
    }

    pub fn get_page(&mut self) -> String {
        let title = self.get_title();
        self.escape_page_name(&title)
    }

    pub fn get_link(&mut self) -> String {
        let path = self.get_path();
        let page = self.get_page();
        join(&path, &page)
    }

    pub fn get_sibling_link(&mut self) -> String {
        let parent = self.parent_link();
        let page = self.get_page();
        join(&parent, &page)
    }

    pub fn get_link_for_title(&mut self, title: &str) -> String {
        let path = self.get_path();
        let page = self.escape_page_name(title);
        join(&path, &page)
    }

    pub fn get_sibling_for_title(&mut self, title: &str) -> String {
        let parent = self.parent_link();
        let page = self.escape_page_name(title);
        join(&parent, &page)
    }

    pub fn get_subpath(&mut self, dir: &str) -> String {
        let base = join(&self.doc_root_path(), dir);
        let generated = self.gen_url();
        join(&base, &generated)
    }

    pub fn render(&mut self, template: &str) -> String {
        let home = self.doc_root_path();
        let title = self.page_title();
        let uptitle = self.parent_page_title();
        let up = self.parent_link();
        let main = self.get_main_html();
        let csslink = self.get_subpath("css");

        // Pass 1 performs every draw in the original document order and keeps
        // the generated values. Link hrefs may only be known after the walk
        // (unresolved ones are drawn afterwards, in slot order), so nothing is
        // written yet; pass 2 assembles the page once, which removes the old
        // full-size marker buffer and the substitution pass that copied it.
        let mut slots: Vec<Slot> = Vec::with_capacity(24);
        let mut pending: Vec<usize> = Vec::with_capacity(24);
        let mut hrefs: Vec<Option<String>> = Vec::with_capacity(24);
        let mut drawn: Vec<String> = Vec::with_capacity(24);
        let mut rest = template;
        loop {
            let pos = match rest.find('{') {
                Some(p) => p,
                None => break,
            };
            let tail = &rest[pos..];
            let end = match tail.find('}') {
                Some(e) => e,
                None => break,
            };
            let name = &tail[1..end];
            rest = &tail[end + 1..];
            match name {
                "WORD" => drawn.push(self.get_word().to_string()),
                "SENTENCE" => drawn.push(self.get_sentence()),
                "NAME" => drawn.push(self.get_name()),
                "PIC" => drawn.push(self.get_subpath("images")),
                "LINK" | "OVER" => {
                    let kind = if name == "LINK" { Kind::Link } else { Kind::Over };
                    let id = slots.len();
                    slots.push(Slot { kind });
                    pending.push(id);
                    hrefs.push(None);
                }
                "NEWTITLE" => {
                    let new_title = self.get_title();
                    if let Some(id) = pending.pop() {
                        let kind = slots[id].kind;
                        let href = match kind {
                            Kind::Link => self.get_link_for_title(&new_title),
                            Kind::Over => self.get_sibling_for_title(&new_title),
                        };
                        hrefs[id] = Some(href);
                    }
                    drawn.push(new_title);
                }
                _ => {}
            }
        }

        // Resolve the links no NEWTITLE bound to, in slot order, preserving
        // the old post-walk RNG order.
        for i in 0..slots.len() {
            if hrefs[i].is_none() {
                hrefs[i] = Some(match slots[i].kind {
                    Kind::Link => self.get_link(),
                    Kind::Over => self.get_sibling_link(),
                });
            }
        }

        // Pass 2 assembles the final page in one pass, sized from the real
        // output so the buffer is never grown mid-write.
        let drawn_len: usize = drawn.iter().map(|s| s.len()).sum();
        let href_len: usize = hrefs.iter().flatten().map(|s| s.len()).sum();
        let mut out = String::with_capacity(
            template.len() + main.len() + drawn_len + href_len + 4096,
        );
        let mut rest = template;
        let mut di = 0usize;
        let mut si = 0usize;
        loop {
            let pos = match rest.find('{') {
                Some(p) => p,
                None => {
                    out.push_str(rest);
                    break;
                }
            };
            out.push_str(&rest[..pos]);
            let tail = &rest[pos..];
            let end = match tail.find('}') {
                Some(e) => e,
                None => {
                    out.push_str(tail);
                    break;
                }
            };
            let name = &tail[1..end];
            rest = &tail[end + 1..];

            match name {
                "HOME" => out.push_str(&home),
                "TITLE" => push_html_escaped(&mut out, &title),
                "UPTITLE" => push_html_escaped(&mut out, &uptitle),
                "UP" => out.push_str(&up),
                "MAIN" => out.push_str(&main),
                "CSSLINK" => out.push_str(&csslink),
                "PIC" => {
                    // PIC is a generated URL, pushed raw by the original code.
                    out.push_str(&drawn[di]);
                    di += 1;
                }
                "WORD" | "SENTENCE" | "NAME" | "NEWTITLE" => {
                    push_html_escaped(&mut out, &drawn[di]);
                    di += 1;
                }
                "LINK" | "OVER" => {
                    if let Some(href) = &hrefs[si] {
                        out.push_str(href);
                    }
                    si += 1;
                }
                _ => {
                    out.push('{');
                    out.push_str(name);
                    out.push('}');
                }
            }
        }
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn doc_root_normalization() {
        assert_eq!(normalize_doc_root("/"), "");
        assert_eq!(normalize_doc_root("///"), "");
        assert_eq!(normalize_doc_root("/blog/"), "/blog");
        assert_eq!(normalize_doc_root("blog"), "/blog");
        assert_eq!(normalize_doc_root(""), "");
    }

    #[test]
    fn join_semantics() {
        assert_eq!(join("", ""), "/");
        assert_eq!(join("", "b"), "/b");
        assert_eq!(join("", "/b"), "/b");
        assert_eq!(join("/blog", "a/b"), "/blog/a/b");
        assert_eq!(join("/blog/", "/a"), "/blog/a");
    }

    #[test]
    fn escape_page_name_strips_unsafe() {
        let corpus = Corpus::embedded();
        let mut r = PageRenderer::new(&corpus, 1, "/", "/x");
        let page = r.escape_page_name("Don't `Stop` Me");
        assert!(!page.contains('\''));
        assert!(!page.contains('`'));
        assert!(!page.contains(' '));
        assert_eq!(page, page.to_lowercase());
    }

    #[test]
    fn render_is_deterministic_per_path() {
        let corpus = Corpus::embedded();
        let assets = crate::assets::Assets::from_dir(std::path::Path::new("assets")).unwrap();
        let mut a = PageRenderer::new(&corpus, 7, "/", "/a-b");
        let first = a.render(assets.template());
        let mut b = PageRenderer::new(&corpus, 7, "/", "/a-b");
        let second = b.render(assets.template());
        assert_eq!(first, second);

        let mut c = PageRenderer::new(&corpus, 7, "/", "/c-d");
        let other = c.render(assets.template());
        assert_ne!(first, other);

        assert!(!first.contains('{'));
        assert!(!first.contains('}'));
        assert!(first.contains("<h1>"));
    }

    #[test]
    fn newtitle_binds_to_preceding_link() {
        let corpus = Corpus::embedded();
        let mut r = PageRenderer::new(&corpus, 3, "/", "/x");
        let html = r.render("<a href=\"{LINK}\">{NEWTITLE}</a>");
        assert!(!html.contains('{'));
        assert!(!html.contains('}'));
        assert!(html.starts_with("<a href=\"/"));
        assert!(html.contains("</a>"));
    }
}
