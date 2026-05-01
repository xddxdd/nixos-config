#!/usr/bin/env python3
import logging
import subprocess
import time

import requests

HYDRA_QUEUE_URL = "https://hydra.lantian.pub/queue"
HYDRA_STATUS_URL = "https://hydra.lantian.pub/status"
CONSECUTIVE_THRESHOLD = 5
CHECK_INTERVAL = 60

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)
log = logging.getLogger(__name__)


def fetch_json(url: str) -> dict:
    resp = requests.get(url, headers={"Accept": "application/json"}, timeout=30)
    resp.raise_for_status()
    return resp.json()


def get_queue_length() -> int:
    data = fetch_json(HYDRA_QUEUE_URL)
    if isinstance(data, list):
        return len(data)
    raise TypeError(f"expected list, got {type(data).__name__}")


def get_running_count() -> int:
    data = fetch_json(HYDRA_STATUS_URL)
    if isinstance(data, list):
        return len(data)
    if isinstance(data, dict):
        return len(data.get("steps", []))
    raise TypeError(f"expected list or dict, got {type(data).__name__}")


def restart_queue_runner() -> None:
    log.warning("restarting hydra-queue-runner.service due to stuck queue")
    subprocess.run(["systemctl", "restart", "hydra-queue-runner.service"])


def main() -> None:
    consecutive_failures = 0

    while True:
        try:
            queue_length = get_queue_length()
            running_count = get_running_count()

            log.info(
                f"queue_length={queue_length}, running_count={running_count}, consecutive_failures={consecutive_failures}"
            )
            if queue_length > 0 and running_count == 0:
                consecutive_failures += 1
            else:
                consecutive_failures = 0

            if consecutive_failures >= CONSECUTIVE_THRESHOLD:
                restart_queue_runner()
                consecutive_failures = 0

        except (requests.RequestException, TypeError) as e:
            log.error(f"failed to fetch status: {e}")

        time.sleep(CHECK_INTERVAL)


if __name__ == "__main__":
    main()
