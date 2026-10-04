#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3
"""Refresh addons.json with the current ATN release of the Thunderbird add-ons
used by the `ayx6omhb.default` profile."""

import base64
import json
import os
import urllib.request

SLUGS = [
    "betterunsubscribe",
    "dkim-verifier",
    "display-mail-user-agent-t",
    "get-all-mail-button-for-tb78",
    "identity-chooser",
    "search-for",
    "simple-startup-minimizer",
    "ublock-origin",
]

API = "https://addons.thunderbird.net/api/v4/addons/addon/{}?lang=en-US"
OUT = os.path.join(os.path.dirname(os.path.realpath(__file__)), "addons.json")


def to_sri(hash_str):
    algo, _, hex_hash = hash_str.partition(":")
    return f"{algo}-{base64.b64encode(bytes.fromhex(hex_hash)).decode()}"


def fetch(slug):
    with urllib.request.urlopen(API.format(slug), timeout=60) as resp:
        addon = json.load(resp)

    version = addon["current_version"]
    if addon["status"] != "public":
        raise RuntimeError(f"{slug} is not public")
    files = [f for f in version["files"] if f["status"] == "public"]
    file = next((f for f in files if f.get("platform") == "all"), files[0])

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
