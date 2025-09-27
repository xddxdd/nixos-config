import os

import requests

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
REPO_OWNERS_TO_CLEANUP = ["xddxdd", "NixOS"]

if not GITHUB_TOKEN:
    print("Error: GITHUB_TOKEN environment variable not set.")
    exit(1)

headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github.v3+json",
}


def get_notifications():
    """Fetches all unread GitHub notifications."""
    url = "https://api.github.com/notifications"
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()


def get_pull_request_status(pr_url):
    """Fetches the status of a pull request (merged/closed)."""
    response = requests.get(pr_url, headers=headers)
    response.raise_for_status()
    pr_data = response.json()
    return pr_data.get("state"), pr_data.get("merged")


def get_issue_status(issue_url):
    """Fetches the status of an issue (closed)."""
    response = requests.get(issue_url, headers=headers)
    response.raise_for_status()
    issue_data = response.json()
    return issue_data.get("state")


def delete_notification(notification_id):
    """Deletes a specific GitHub notification."""
    url = f"https://api.github.com/notifications/threads/{notification_id}"
    response = requests.delete(url, headers=headers)
    response.raise_for_status()
    print(f"Deleted notification {notification_id}")


def main():
    print("Fetching GitHub notifications...")
    notifications = get_notifications()
    print(f"Found {len(notifications)} notifications.")

    for notification in notifications:
        if notification["repository"]["owner"]["login"] not in REPO_OWNERS_TO_CLEANUP:
            continue

        notification_type = notification["subject"]["type"]
        notification_url = notification["subject"]["url"]

        if not notification_url:
            print(f"Skipping notification {notification['id']} due to missing URL.")
            continue

        try:
            should_delete = False
            if notification_type == "PullRequest":
                state, merged = get_pull_request_status(notification_url)
                if state == "closed" or merged:
                    should_delete = True
            elif notification_type == "Issue":
                state = get_issue_status(notification_url)
                if state == "closed":
                    should_delete = True

            if should_delete:
                print(
                    f"Notification ID: {notification['id']}, Subject: {notification['subject']['title']}, Repo: {notification['repository']['full_name']}"
                )
                delete_notification(notification["id"])
        except requests.exceptions.RequestException as e:
            print(
                f"Error fetching status for {notification_url} ({notification_type}): {e}"
            )


if __name__ == "__main__":
    main()
