#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p wget
# shellcheck shell=bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
TEMPFILE=$(mktemp)
wget https://gitea.com/robots.txt -O "$TEMPFILE"
mv "$TEMPFILE" "$SCRIPT_DIR/robots.txt"
