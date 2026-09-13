#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.requests
# Remove Sonarr queue entries stuck on "Episode file already imported",
# "Not a Custom Format upgrade for existing episode file(s)" or "Not an
# upgrade for existing episode file(s)".
#
# These appear when a release is tracked as a season pack but the torrent
# only contains a single episode file: the file gets imported (or discarded
# as a non-upgrade), yet one queue entry per episode of the season lingers
# in the activity queue forever. Sonarr will never import anything more
# from such a download, so it can be safely removed, including the torrent
# from the download client.
#
# A download is only deleted when ALL of its queue entries carry one of
# those messages, all meaning the entry has nothing left to import:
# "Episode file already imported" is Sonarr's download-level accounting
# that every file it contains was already imported, while the two "not an
# upgrade" messages mean the library already holds a file at least as good
# as what the download offers. If any entry of the download carries none
# of them, the download may still hold unimported content and is left
# untouched.

import os
import sys
import xml.etree.ElementTree as ET

import requests

SONARR_URL = os.environ["SONARR_URL"].rstrip("/")
CONFIG_XML = os.environ.get("SONARR_CONFIG", "/var/lib/sonarr/config.xml")
DRY_RUN = "DRY_RUN" in os.environ
PAGE_SIZE = 200
# Status messages that mean a queue entry has nothing left to import.
MARKERS = [
    "episode file already imported",
    "not a custom format upgrade",
    "not an upgrade for existing episode file",
]


def get_api_key():
    if os.environ.get("SONARR_API_KEY"):
        return os.environ["SONARR_API_KEY"]
    api_key = ET.parse(CONFIG_XML).findtext("./ApiKey")
    if not api_key:
        print(f"Error: ApiKey not found in {CONFIG_XML}")
        sys.exit(1)
    return api_key


def get_queue(session):
    records = []
    page = 1
    while True:
        try:
            response = session.get(
                f"{SONARR_URL}/api/v3/queue",
                params={"page": page, "pageSize": PAGE_SIZE},
            )
            response.raise_for_status()
            data = response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching queue page {page}: {e}")
            sys.exit(1)
        records.extend(data["records"])
        if not data["records"] or len(records) >= data["totalRecords"]:
            return records
        page += 1


def is_affected(record):
    if record.get("status") != "completed":
        return False
    messages = [
        message
        for status_message in record.get("statusMessages") or []
        for message in status_message.get("messages") or []
    ]
    return any(marker in message.lower() for message in messages for marker in MARKERS)


def select_targets(records):
    affected = [record for record in records if is_affected(record)]
    if not affected:
        return [], [], []

    entries_by_download = {}
    for record in records:
        if record.get("downloadId"):
            entries_by_download.setdefault(record["downloadId"], []).append(record)

    # Only delete a download when every queue entry of that download has
    # nothing left to import; otherwise it may still hold unimported content.
    targets = []
    skipped = []
    handled_downloads = set()
    for record in affected:
        download_id = record.get("downloadId")
        if not download_id:
            # Not tied to a download client; remove the lone entry itself.
            targets.append(record)
        elif download_id not in handled_downloads:
            handled_downloads.add(download_id)
            siblings = entries_by_download[download_id]
            if all(is_affected(sibling) for sibling in siblings):
                targets.extend(siblings)
            else:
                pending = sum(1 for sibling in siblings if not is_affected(sibling))
                skipped.append((record["title"], len(siblings), pending))
    return affected, targets, skipped


def delete_targets(session, targets):
    deleted = 0
    already_gone = 0
    failed = 0
    for record in targets:
        try:
            response = session.delete(
                f"{SONARR_URL}/api/v3/queue/{record['id']}",
                params={"removeFromClient": "true", "blocklist": "false"},
            )
            if response.status_code == 404:
                # Removing one entry of a download takes the whole tracked
                # download with it, so its sibling entries are already gone.
                already_gone += 1
            elif response.ok:
                deleted += 1
                print(f"Deleted #{record['id']} {record['title']}")
            else:
                failed += 1
                print(
                    f"Error deleting #{record['id']} {record['title']}: "
                    f"HTTP {response.status_code} {response.text}",
                    file=sys.stderr,
                )
        except requests.exceptions.RequestException as e:
            failed += 1
            print(
                f"Error deleting #{record['id']} {record['title']}: {e}",
                file=sys.stderr,
            )
    return deleted, already_gone, failed


def main():
    sys.stdout.reconfigure(line_buffering=True)
    session = requests.Session()
    session.headers["X-Api-Key"] = get_api_key()

    records = get_queue(session)
    affected, targets, skipped = select_targets(records)
    if not affected:
        print("No stuck queue entries found.")
        return

    print(
        f"Found {len(affected)} eligible queue entries "
        "(already imported / not an upgrade); "
        f"deleting {len(targets)} entries from {len({r.get('downloadId') for r in targets if r.get('downloadId')})} "
        "fully imported downloads."
    )
    for title, total, pending in skipped:
        print(
            f"Skipping {title}: {pending}/{total} entries not yet imported, "
            "download may hold unimported content"
        )

    if DRY_RUN:
        print("Dry run, no changes will be made:")
        for record in targets:
            print(f"Would delete #{record['id']} {record['title']}")
        return

    deleted, already_gone, failed = delete_targets(session, targets)
    if failed:
        print(f"Failed to delete {failed}/{len(targets)} queue entries.")
        sys.exit(1)
    print(f"Deleted {deleted} queue entries ({already_gone} already gone).")


if __name__ == "__main__":
    main()
