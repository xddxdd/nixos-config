#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.requests -p python3Packages.pydantic
import os
import sys
from datetime import datetime, timedelta, timezone  # Import timezone

import requests
from pydantic import BaseModel, Field, ValidationError


# Pydantic model for a qBittorrent torrent
class Torrent(BaseModel):
    hash: str = Field(alias="hash")  # Add hash field, essential for deletion
    name: str = Field(alias="name")
    category: str = Field(default="N/A", alias="category")
    save_path: str = Field(alias="save_path")
    progress: float = Field(alias="progress")  # float from 0 to 1
    added_on: datetime = Field(
        alias="added_on"
    )  # Pydantic converts Unix timestamp to datetime

    @property
    def progress_percent(self) -> str:
        return f"{self.progress:.2%}"

    @property
    def creation_time(self) -> str:
        # Pydantic automatically converts the timestamp to datetime
        return self.added_on.strftime("%Y-%m-%d %H:%M:%S")

    @property
    def is_completed(self) -> bool:
        return self.progress >= 1.0

    @property
    def time_since_creation(self) -> timedelta:
        # Ensure both datetimes are timezone-aware (UTC) for subtraction
        # Pydantic's conversion of 'added_on' from a Unix timestamp might yield a naive datetime.
        # So, we explicitly make it UTC-aware before subtraction if it's naive.
        current_time_utc = datetime.now(timezone.utc)
        added_on_utc = (
            self.added_on.replace(tzinfo=timezone.utc)
            if self.added_on.tzinfo is None
            else self.added_on
        )
        return current_time_utc - added_on_utc


# Filter function
def should_include_torrent(torrent: Torrent) -> bool:
    if torrent.save_path != "/mnt/ssd-temp/.downloads-auto":
        return False

    if not torrent.is_completed and torrent.time_since_creation > timedelta(hours=36):
        return True

    if torrent.is_completed and torrent.time_since_creation > timedelta(days=5):
        return True

    # If none of the above conditions are met, exclude the torrent
    return False


# Get qBittorrent URL from environment variable or use default
QBITTORRENT_URL = os.environ["QBITTORRENT_URL"]


def get_qbittorrent_api_url():
    # qBittorrent API usually resides under /api/v2/
    return f"{QBITTORRENT_URL}/api/v2/"


def login(session, api_url):
    # For no-password setup, a simple GET to a protected endpoint might be enough to verify session
    # However, qBittorrent API generally expects a POST to /auth/login even without credentials
    login_url = f"{api_url}auth/login"
    try:
        response = session.post(login_url)
        response.raise_for_status()
        if (
            "Fails" in response.text
        ):  # Older qbittorrent versions might return "Fails" for failed login
            print("Login failed, please check qBittorrent URL or credentials.")
            sys.exit(1)
        print("Login successful (or not required for this setup).")
        return True
    except requests.exceptions.RequestException as e:
        print(f"Error during login: {e}")
        sys.exit(1)
    return False


def get_all_torrents(session, api_url) -> list[Torrent]:
    torrents_url = f"{api_url}torrents/info"
    try:
        response = session.get(torrents_url)
        response.raise_for_status()
        torrents_data = response.json()

        torrent_objects = []
        for torrent_dict in torrents_data:
            try:
                # Pydantic will automatically convert 'added_on' from int timestamp to datetime
                torrent_objects.append(Torrent.model_validate(torrent_dict))
            except ValidationError as e:
                print(
                    f"Error validating torrent data: {e} for torrent: {torrent_dict.get('name', 'N/A')}"
                )
        return torrent_objects
    except requests.exceptions.RequestException as e:
        print(f"Error fetching torrents: {e}")
        sys.exit(1)
    return []


def delete_torrent(session, api_url, torrent_hash: str):
    delete_url = f"{api_url}torrents/delete"
    params = {
        "hashes": torrent_hash,
        "deleteFiles": "true",  # Delete associated files
    }
    try:
        response = session.post(delete_url, data=params)
        response.raise_for_status()
        return True
    except requests.exceptions.RequestException as e:
        print(f"Error deleting torrent {torrent_hash}: {e}")
        return False


def main():
    print("Connecting to qBittorrent service...")
    session = requests.Session()
    api_url = get_qbittorrent_api_url()

    # Attempt login (even if no password, some versions might need this call)
    login(session, api_url)

    torrents = get_all_torrents(session, api_url)
    if not torrents:
        print("No torrents found or an error occurred.")
        return

    filtered_torrents = [
        torrent for torrent in torrents if should_include_torrent(torrent)
    ]
    if not filtered_torrents:
        print("No torrents found matching the filter criteria to delete.")
        return

    print(f"Found {len(filtered_torrents)} torrents matching criteria for deletion.")
    print("\n--- Deleting Torrents ---")
    deleted_count = 0
    for torrent in filtered_torrents:
        print(f"Attempting to delete: {torrent.name} (Hash: {torrent.hash})")
        if delete_torrent(session, api_url, torrent.hash):
            print(f"Successfully deleted: {torrent.name}")
            deleted_count += 1
        else:
            print(f"Failed to delete: {torrent.name}")

    if deleted_count > 0:
        print(f"\n--- Successfully deleted {deleted_count} torrents. ---")
    else:
        print("\n--- No torrents were deleted. ---")


if __name__ == "__main__":
    main()
