#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3
"""
Fetch the Mozilla translations model registry (db/models.json), pick one
released model per language pair (largest variant; only Release / Release
Desktop / Release Android are considered), download every asset to hash it,
and write models.json next to this script as a flat

    "<pair>/<filename>" -> { "url", "sha256" }

mapping consumed by ./default.nix via pkgs.linkFarm.
"""

import concurrent.futures
import hashlib
import json
import os
import re
import sys
import urllib.request

SCRIPT_DIR = os.path.dirname(os.path.realpath(sys.argv[0]))

REGISTRY_URL = (
    "https://storage.googleapis.com/"
    "moz-fx-translations-data--303e-prod-translations-data/db/models.json"
)

RELEASED_STATUSES = ("Release", "Release Desktop", "Release Android")

# LinguaSpark only accepts ISO 639-1 codes (exactly two lowercase letters), so
# pairs like en-zh_hant or hbs-en are unusable and must be skipped.
ISO_639_1 = re.compile(r"[a-z]{2}")


def is_two_letter_pair(pair):
    return all(ISO_639_1.fullmatch(p) for p in pair.split("-"))


def http_get(url, retries=3, timeout=120):
    last = None
    for _ in range(retries):
        try:
            with urllib.request.urlopen(url, timeout=timeout) as r:
                return r.read()
        except Exception as e:  # noqa: BLE001
            last = e
    raise RuntimeError(f"failed to fetch {url}: {last}")


def sha256_of(url):
    h = hashlib.sha256()
    with urllib.request.urlopen(url, timeout=300) as r:
        for chunk in iter(lambda: r.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def file_paths(model):
    files = model["files"]
    paths = [
        files["model"]["path"],
        files["lexicalShortlist"]["path"],
    ]
    if "vocab" in files:
        paths.append(files["vocab"]["path"])
    else:
        paths.append(files["srcVocab"]["path"])
        paths.append(files["trgVocab"]["path"])
    return paths


def load_existing():
    path = os.path.join(SCRIPT_DIR, "models.json")
    if not os.path.exists(path):
        return {}
    try:
        return json.load(open(path))
    except Exception:
        return {}


def main():
    registry = json.loads(http_get(REGISTRY_URL))
    base_url = registry["baseUrl"]

    # One released model per pair: largest by uncompressed model size. Each
    # pair has at most one model per architecture, so this is the largest
    # variant available.
    targets = {}  # "<pair>/<file>" -> url
    for pair, variants in registry["models"].items():
        if not is_two_letter_pair(pair):
            continue
        released = [m for m in variants if m.get("releaseStatus") in RELEASED_STATUSES]
        if not released:
            continue
        best = max(
            released,
            key=lambda m: (
                m["files"]["model"].get("uncompressedSize", 0),
                m.get("modelStatistics", {}).get("parameters", 0),
            ),
        )
        for path in file_paths(best):
            targets[f"{pair}/{os.path.basename(path)}"] = f"{base_url}/{path}"

    # Reuse hashes from an existing models.json when the URL is unchanged, so
    # re-runs skip re-downloading unchanged assets.
    existing = load_existing()
    hashes = {
        k: existing[k]["sha256"]
        for k in targets
        if k in existing and existing[k].get("url") == targets[k]
    }
    todo = {k: targets[k] for k in targets if k not in hashes}
    print(
        f"hashing {len(todo)} assets ({len(hashes)} cached) across "
        f"{len({k.split('/')[0] for k in targets})} pairs",
        file=sys.stderr,
    )
    with concurrent.futures.ThreadPoolExecutor(max_workers=16) as ex:
        hashes.update(dict(zip(todo.keys(), ex.map(sha256_of, todo.values()))))

    out = {k: {"url": targets[k], "sha256": hashes[k]} for k in sorted(targets)}
    with open(os.path.join(SCRIPT_DIR, "models.json"), "w") as fh:
        json.dump(out, fh, indent=2, sort_keys=True)
        fh.write("\n")
    print("wrote models.json", file=sys.stderr)


if __name__ == "__main__":
    main()
