#!/usr/bin/env python3
"""fastpit corpus pipeline.

Subcommands:
  extract   build templates.json + word_pools.json from the nltk treebank
  pack      build corpus.bin (Cap'n Proto) from the JSON
  all       extract then pack
  generate  print sample sentences from the JSON (reference generator)

Heavy dependencies are imported lazily inside their subcommand: nltk only for
`extract`, pycapnp only for `pack`. The field layout and ordering invariants
that keep the generated site byte-identical are in data/FORMAT.md.
"""

import json
import os
import random
import re
import sys
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))


def _default(name):
    return os.path.join(HERE, name)


# --------------------------------------------------------------------------
# shared corpus constants
# --------------------------------------------------------------------------
CONTENT_TAGS = {
    "NN",
    "NNS",
    "NNP",
    "NNPS",
    "VB",
    "VBD",
    "VBG",
    "VBN",
    "VBP",
    "VBZ",
    "JJ",
    "JJR",
    "JJS",
    "RB",
    "RBR",
    "RBS",
    "CD",
}
# tags that stay as treebank literals in templates but get pooled words at generation
FUNCTION_TAGS = {
    "DT",
    "PDT",
    "IN",
    "POS",
    "CC",
    "MD",
    "TO",
    "PRP",
    "PRP$",
    "EX",
    "WDT",
    "WP",
    "WP$",
    "WRB",
    "RP",
    "UH",
}
PUNCT = {
    ".": ".",
    ",": ",",
    ":": ";",
    "-LRB-": "(",
    "-RRB-": ")",
    "``": '"',
    "''": '"',
    "$": "$",
    "HYPH": "-",
    "#": "#",
}

MAGIC = 0x0054495054534146
VERSION = 4
ABSENT = 0xFFFFFFFF

WORDNET_MERGED_TAGS = ("NN", "VB", "JJ", "RB")

# PARAMS generation rules for the standard corpus.
NUMBER_MIN = 1
NUMBER_MAX = 100
FLAGS = 0b11  # bit 0: a->an before a vowel; bit 1: capitalize the first letter

# PARAMS.attach[tag] derived from the tag name (FORMAT.md "Ordering and
# determinism invariants" #6): 1 attach left, 2 attach right, 3 attach both.
ATTACH_LEFT = (".", ",", ";", "-RRB-", "''", "POS")
ATTACH_RIGHT = ("-LRB-", "``", "$")
ATTACH_BOTH = ("HYPH",)


def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def attach_mode(tag):
    if tag in ATTACH_LEFT:
        return 1
    if tag in ATTACH_RIGHT:
        return 2
    if tag in ATTACH_BOTH:
        return 3
    return 0


# --------------------------------------------------------------------------
# extract
# --------------------------------------------------------------------------
def clean(word):
    return word.replace("\\/", "/")


def is_word(w):
    return re.fullmatch(r"[a-z][a-z.'-]*", w) and not re.fullmatch(r"[.\d]+", w)


def extract(args):
    import nltk
    from nltk.corpus import names as names_corpus
    from nltk.corpus import treebank, wordnet

    _ = nltk
    for path in (args["templates"], args["pools"]):
        d = os.path.dirname(os.path.abspath(path))
        if d:
            os.makedirs(d, exist_ok=True)

    templates = defaultdict(lambda: {"count": 0, "example": None, "slots": []})
    function_words = defaultdict(Counter)
    content_words = defaultdict(Counter)

    for tree in treebank.parsed_sents():
        tokens = [(w, t) for w, t in tree.pos() if t != "-NONE-"]
        leaves = tokens
        if not (4 <= len(leaves) <= 22):
            continue
        if not any(t == "." for _, t in leaves) or "-RRB-" in (t for _, t in leaves):
            continue

        key = tuple(t for _, t in leaves)
        entry = templates[key]
        entry["count"] += 1
        if entry["example"] is None:
            entry["example"] = " ".join(w for w, _ in leaves)
            entry["slots"] = [t for _, t in leaves]
        for word, tag in leaves:
            word = clean(word.lower())
            if tag in FUNCTION_TAGS:
                function_words[tag][word] += 1
            elif tag in CONTENT_TAGS:
                if tag not in ("CD",) and is_word(word):
                    content_words[tag][word] += 1
            elif tag in PUNCT:
                pass
            elif tag not in ("SYM", "LS"):
                print("unhandled tag:", tag, word)

    # proper nouns: treebank ones are too news-specific (company tickers, 'j.l.'); use names corpus
    nnp = [n.lower() for n in names_corpus.words() if is_word(n.lower())]
    content_words["NNP"] = Counter({w: 1 for w in nnp})
    wn_map = {"NN": "n", "VB": "v", "JJ": "a", "RB": "r"}
    wn_extra = {}
    for tag, pos in wn_map.items():
        words = {
            l.name().replace("_", " ")
            for s in wordnet.all_synsets(pos)
            for l in s.lemmas()
        }
        words = {w for w in words if re.fullmatch(r"[a-z][a-z-]{2,}", w)}
        wn_extra[tag] = sorted(words)
        print(f"{tag}: treebank {len(content_words[tag])} + wordnet {len(words)}")

    out_templates = [
        {
            "tags": list(key),
            "count": e["count"],
            "example": e["example"],
        }
        for key, e in sorted(templates.items(), key=lambda kv: -kv[1]["count"])
    ]
    with open(args["templates"], "w") as f:
        json.dump(out_templates, f, indent=1)

    pools = {"function": {}, "content": {}, "punct": PUNCT, "wordnet": wn_extra}
    for tag, c in function_words.items():
        pools["function"][tag] = [w for w, n in c.most_common(20)]
    for tag, c in content_words.items():
        pools["content"][tag] = [
            w
            for w, n in c.most_common()
            if n >= 2 or tag in ("NNP", "CD", "VBG", "VBN", "NNS")
        ]
    with open(args["pools"], "w") as f:
        json.dump(pools, f, indent=1)

    n_total = sum(e["count"] for e in out_templates)
    print(
        f"templates: {len(out_templates)} unique, {n_total} sentences kept of {len(treebank.parsed_sents())}"
    )


# --------------------------------------------------------------------------
# pack
# --------------------------------------------------------------------------
def build(templates_json, pools_json):
    content = pools_json["content"]
    function = pools_json["function"]
    punct = pools_json["punct"]
    wordnet = pools_json["wordnet"]

    content_merged = {tag: list(words) for tag, words in content.items()}
    for tag in WORDNET_MERGED_TAGS:
        content_merged.setdefault(tag, []).extend(wordnet.get(tag, []))

    def renderable(tag):
        return tag == "CD" or tag in punct or tag in content_merged or tag in function

    kept = [t for t in templates_json if all(renderable(tag) for tag in t["tags"])]

    universe = set()
    for words in list(content_merged.values()) + list(function.values()):
        for word in words:
            if len(word) >= 2 and all("a" <= c <= "z" for c in word):
                universe.add(word)
    universe = sorted(universe)

    # Every tag the file exposes, plus CD (filled numerically, no pool).
    tags = sorted(set(content_merged) | set(function) | set(punct) | {"CD"})

    referenced = set(tags)
    for words in list(content_merged.values()) + list(function.values()):
        referenced.update(words)
    referenced.update(punct.values())

    remaining = sorted(referenced - set(universe))
    strings = universe + remaining
    string_id = {s: i for i, s in enumerate(strings)}

    tag_index = {tag: i for i, tag in enumerate(tags)}

    return {
        "kept": kept,
        "universe": universe,
        "tags": tags,
        "strings": strings,
        "string_id": string_id,
        "tag_index": tag_index,
        "content_merged": content_merged,
        "function": function,
        "punct": punct,
    }


def pack_message(built, schema_path):
    import capnp

    tags = built["tags"]
    strings = built["strings"]
    string_id = built["string_id"]

    blob = "".join(strings).encode("utf-8")
    offsets = [0]
    for s in strings:
        offsets.append(offsets[-1] + len(s.encode("utf-8")))

    content_items = []
    function_items = []
    content_off = [0]
    function_off = [0]
    punct_str = []
    for tag in tags:
        for word in built["content_merged"].get(tag, []):
            content_items.append(string_id[word])
        content_off.append(len(content_items))

        for word in built["function"].get(tag, []):
            function_items.append(string_id[word])
        function_off.append(len(function_items))

        punct_str.append(
            string_id[built["punct"][tag]] if tag in built["punct"] else ABSENT
        )

    template_tags = []
    template_off = [0]
    for template in built["kept"]:
        for tag in template["tags"]:
            template_tags.append(built["tag_index"][tag])
        template_off.append(len(template_tags))

    cd_tag = tags.index("CD") if "CD" in tags else ABSENT

    message = capnp.load(schema_path).Corpus.new_message()
    message.magic = MAGIC
    message.version = VERSION
    message.wordBlob = blob
    message.wordOffsets = offsets
    message.universeLen = len(built["universe"])
    message.tagStrings = [string_id[tag] for tag in tags]
    message.contentOff = content_off
    message.functionOff = function_off
    message.punctString = punct_str
    message.contentItems = content_items
    message.functionItems = function_items
    message.templateOff = template_off
    message.templateTags = template_tags
    message.numberTag = cd_tag
    message.numberMin = NUMBER_MIN
    message.numberMax = NUMBER_MAX
    message.flags = FLAGS
    message.attach = [attach_mode(tag) for tag in tags]
    return message


def pack(args):
    built = build(load_json(args["templates"]), load_json(args["pools"]))
    message = pack_message(built, args["schema"])
    blob = message.to_bytes()

    with open(args["out"], "wb") as f:
        f.write(blob)

    print(f"kept templates:   {len(built['kept'])}")
    print(f"distinct tags:    {len(built['tags'])}")
    print(f"distinct strings: {len(built['strings'])}")
    print(f"universe:         {len(built['universe'])}")
    content_total = sum(len(v) for v in built["content_merged"].values())
    function_total = sum(len(v) for v in built["function"].values())
    print("content items:    %d" % content_total)
    print("function items:   %d" % function_total)
    print(f"total file size:  {len(blob)} bytes")


# --------------------------------------------------------------------------
# generate
# --------------------------------------------------------------------------
def generate(args):
    templates = load_json(args["templates"])
    pools = load_json(args["pools"])
    random.seed(args["seed"])

    attach_left = {".", ",", ";", "-RRB-", "''", "POS"}
    attach_right = {"-LRB-", "``", "$"}
    attach_both = {"HYPH"}

    def fill(tags):
        out = []
        for tag in tags:
            if tag == "CD":
                out.append((tag, str(random.randint(1, 100))))
            elif tag in pools["punct"]:
                out.append((tag, pools["punct"][tag]))
            elif tag in pools["content"] and pools["content"][tag]:
                out.append((tag, random.choice(pools["content"][tag])))
            elif tag in pools["function"]:
                out.append((tag, random.choice(pools["function"][tag])))
            else:
                out.append((tag, tag))
        for i, (tag, w) in enumerate(out[:-1]):
            if w == "a" and re.match(r"[aeiou]", out[i + 1][1]):
                out[i] = (tag, "an")
        s = ""
        glue_next = False
        for tag, w in out:
            if tag in attach_left or tag in attach_both:
                s += w
            elif glue_next:
                s += w
            else:
                s += " " + w
            glue_next = tag in attach_right or tag in attach_both
        s = s.lstrip()
        return re.sub(r"[a-z]", lambda m: m.group().upper(), s, count=1)

    for _ in range(args["count"]):
        print(fill(random.choice(templates)["tags"]))


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------
USAGE = """usage: python3 data/corpus.py <command> [options]

commands:
  extract              build templates.json + word_pools.json from the nltk treebank
  pack                 build corpus.bin (Cap'n Proto) from the JSON
  all                  extract then pack
  generate             print sample sentences from the JSON

options:
  --templates PATH     templates.json (default: <script dir>/templates.json)
  --pools PATH         word_pools.json (default: <script dir>/word_pools.json)
  --out PATH           pack output corpus.bin (default: <script dir>/corpus.bin)
  --schema PATH        Cap'n Proto schema (default: <script dir>/corpus.capnp)
  -n, --count N        generate: number of sentences (default: 10)
  --seed N             generate: RNG seed (default: 0)
  -h, --help           show this help"""


def parse_args(argv):
    """Return (command, opts) or ("help", None) or (None, None) on error."""
    if not argv:
        return None, None
    cmd = argv[0]
    if cmd in ("-h", "--help"):
        return "help", None
    if cmd not in ("extract", "pack", "all", "generate"):
        return None, None

    opts = {
        "templates": _default("templates.json"),
        "pools": _default("word_pools.json"),
        "out": _default("corpus.bin"),
        "schema": _default("corpus.capnp"),
        "count": 10,
        "seed": 0,
    }
    takes_value = {
        "--templates": "templates",
        "--pools": "pools",
        "--out": "out",
        "--schema": "schema",
        "-n": "count",
        "--count": "count",
        "--seed": "seed",
    }
    i = 1
    while i < len(argv):
        a = argv[i]
        if a in ("-h", "--help"):
            return "help", None
        if a not in takes_value or i + 1 >= len(argv):
            return None, None
        key = takes_value[a]
        try:
            opts[key] = int(argv[i + 1]) if key in ("count", "seed") else argv[i + 1]
        except ValueError:
            return None, None
        i += 2
    return cmd, opts


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    cmd, opts = parse_args(argv)
    if cmd == "help":
        print(USAGE)
        return 0
    if cmd is None:
        print(USAGE, file=sys.stderr)
        return 2
    if cmd == "extract":
        extract(opts)
    elif cmd == "pack":
        pack(opts)
    elif cmd == "all":
        extract(opts)
        pack(opts)
    elif cmd == "generate":
        generate(opts)
    return 0


if __name__ == "__main__":
    sys.exit(main())
