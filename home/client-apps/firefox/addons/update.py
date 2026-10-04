#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3
"""Refresh addons.json with the current AMO release of every add-on listed in
home/client-apps/firefox/default.nix, except auto-novel-addon (nvfetcher)."""

import base64
import json
import os
import urllib.request

SLUGS = [
    "adnauseam",
    "all-api-hub",
    "awardwallet",
    "bilisponsorblock",
    "bitwarden-password-manager",
    "cardpointers-x",
    "clearurls",
    "darkreader",
    "dont-track-me-google1",
    "downthemall",
    "fastforwardteam",
    "foxyproxy-standard",
    "i-dont-care-about-cookies",
    "ipfs-companion",
    "lovely-forks",
    "multi-account-containers",
    "noscript",
    "pakkujs",
    "pay-by-privacy",
    "phantom-app",
    "plasma-integration",
    "protondb-for-steam",
    "pt-depiler",
    "read-frog-open-ai-translator",
    "redirector",
    "return-youtube-dislikes",
    "rsshub-radar",
    "sponsorblock",
    "steam-database",
    "tab-reloader",
    "tampermonkey",
    "tweaks-for-youtube",
    "ublacklist",
    "wappalyzer",
]

API = "https://addons.mozilla.org/api/v5/addons/addon/{}?lang=en-US"
OUT = os.path.join(os.path.dirname(os.path.realpath(__file__)), "addons.json")


def to_sri(hash_str):
    algo, _, hex_hash = hash_str.partition(":")
    return f"{algo}-{base64.b64encode(bytes.fromhex(hex_hash)).decode()}"


def fetch(slug):
    with urllib.request.urlopen(API.format(slug), timeout=60) as resp:
        addon = json.load(resp)

    version = addon["current_version"]
    file = version["file"]
    if addon["status"] != "public" or file["status"] != "public":
        raise RuntimeError(f"{slug} is not public")

    return {
        "pname": slug,
        "version": version["version"],
        "url": file["url"],
        "hash": to_sri(file["hash"]),
        "addonId": addon["guid"],
    }


addons = sorted((fetch(slug) for slug in SLUGS), key=lambda a: a["pname"])
with open(OUT, "w") as f:
    json.dump(addons, f, indent=2)
    f.write("\n")
