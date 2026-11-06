#!/usr/bin/env python3
"""
Scan VSCode "Open Recent" projects and write a JSON cache for the
lantian/vscode-projects launcher plugin.

Sources (read-only):
1. history.recentlyOpenedPathsList from the application-shared state.vscdb,
   in list order = most-recently-first.
2. workspaceStorage/*/workspace.json, for windows not yet in the recents list;
   ordered by their state.vscdb mtime, newest first.

Output: [{"path": ..., "name": ...}, ...] minus paths inside the Nix store or
VSCode's own config dir, and minus paths that no longer exist on disk.
"""

import json
import os
import re
import sqlite3
import sys

HOME = os.path.expanduser("~")
RECENTS_DB = os.path.join(HOME, ".vscode-shared/sharedStorage/state.vscdb")
WS_STORAGE = os.path.join(HOME, ".config/Code/User/workspaceStorage")

RECENT_KEY = "history.recentlyOpenedPathsList"


def decode_uri(uri: str) -> str:
    if not uri.startswith("file://"):
        return ""
    return re.sub(r"%([0-9A-Fa-f]{2})", lambda m: chr(int(m.group(1), 16)), uri[7:])


def from_recents_db() -> list[str]:
    # Prefer the authoritative SQL value; fall back to a byte scan (the JSON
    # value is contiguous) when the db cannot be opened, e.g. writer lock.
    stored = None
    try:
        conn = sqlite3.connect(f"file:{RECENTS_DB}?mode=ro", uri=True)
        try:
            row = conn.execute(
                "SELECT value FROM ItemTable WHERE key = ?", (RECENT_KEY,)
            ).fetchone()
            stored = row[0] if row else None
        finally:
            conn.close()
    except sqlite3.Error:
        stored = None
    if stored is not None:
        entries = json.loads(stored).get("entries") or []
        uris = []
        for entry in entries:
            uri = entry.get("folderUri") or entry.get("workspaceUri")
            if uri:
                uris.append(uri)
        return uris
    raw = open(RECENTS_DB, "rb").read()
    matches = re.findall(rb'(folderUri|workspaceUri)":"(file://[^"]*)"', raw)
    return [m.group(2).decode() for m in matches]


def from_workspace_storage() -> list[tuple[str, float]]:
    entries = []
    try:
        hashes = os.listdir(WS_STORAGE)
    except OSError:
        hashes = []
    for h in hashes:
        try:
            with open(os.path.join(WS_STORAGE, h, "workspace.json")) as f:
                meta = json.load(f)
        except (OSError, ValueError):
            continue
        uri = meta.get("folder") or meta.get("workspace")
        if not uri or not uri.startswith("file://"):
            continue
        try:
            mtime = os.path.getmtime(os.path.join(WS_STORAGE, h, "state.vscdb"))
        except OSError:
            mtime = os.path.getmtime(os.path.join(WS_STORAGE, h))
        entries.append((decode_uri(uri), mtime))
    entries.sort(key=lambda e: e[1], reverse=True)
    return entries


def main() -> int:
    cache_path = sys.argv[1] if len(sys.argv) > 1 else ""
    if not cache_path:
        return 2

    items = []
    seen = set()
    for uri in from_recents_db():
        path = decode_uri(uri)
        if path and path not in seen:
            seen.add(path)
            items.append(path)
    for path, _ in from_workspace_storage():
        if path and path not in seen:
            seen.add(path)
            items.append(path)

    result = []
    for path in items:
        if path.startswith("/nix/store/"):
            continue
        if path.startswith(HOME + "/.config/Code/"):
            continue
        if not os.path.isdir(path):
            continue
        result.append({"path": path, "name": os.path.basename(path) or path})

    # 每个进程用独立临时名：并发运行的 scan（旧、新 runtime 交替时）
    # 各自 rename 原子提交，不互相抢同一个 tmp
    tmp = f"{cache_path}.{os.getpid()}.tmp"
    try:
        with open(tmp, "w") as f:
            json.dump(result, f)
        os.replace(tmp, cache_path)
    finally:
        if os.path.exists(tmp):
            os.remove(tmp)
    return 0


if __name__ == "__main__":
    sys.exit(main())
