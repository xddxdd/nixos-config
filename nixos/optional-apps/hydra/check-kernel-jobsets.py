#!/usr/bin/env python3

import os
import sys

import requests

HYDRA_URL = os.environ["HYDRA_URL"]
PROJECT = "lantian"
JOBSETS = ["nix-cachyos-kernel", "nix-cachyos-kernel-release"]
HEADERS = {"Accept": "application/json", "User-Agent": "hydra-check-kernel-jobsets"}


def get(path: str):
    r = requests.get(f"{HYDRA_URL}{path}", headers=HEADERS)
    r.raise_for_status()
    return r.json()


def failed_nixos_configurations(jobset: str) -> list[dict]:
    evals = get(f"/jobset/{PROJECT}/{jobset}/evals")["evals"]
    if not evals:
        raise RuntimeError(f"jobset {PROJECT}/{jobset} has no evaluation")
    eval_id = evals[0]["id"]

    builds = [
        b
        for b in get(f"/eval/{eval_id}/builds")
        if b["job"].startswith("nixosConfigurations.")
    ]
    failed = [b for b in builds if b["finished"] and b["buildstatus"] != 0]

    print(
        f"{PROJECT}/{jobset} eval {eval_id}: {len(builds)} nixosConfigurations builds"
    )
    for b in failed:
        print(f"  FAILED {b['job']} (build {b['id']}, buildstatus {b['buildstatus']})")
    return failed


def main() -> int:
    failures = []
    for jobset in JOBSETS:
        failures += failed_nixos_configurations(jobset)
    if failures:
        print(f"{len(failures)} nixosConfigurations build(s) failed")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
