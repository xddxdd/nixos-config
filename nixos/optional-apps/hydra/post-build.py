#!/usr/bin/env python3

import logging
import os
import re
import subprocess
import sys
import tempfile
from datetime import datetime
from typing import List, Optional, Self

import requests
from pydantic import BaseModel

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler(sys.stdout)],
)

HYDRA_URL = os.environ["HYDRA_URL"]


class BuildOutput(BaseModel):
    name: str
    path: str


class BuildEvent(BaseModel):
    metrics: List[dict] = []
    products: List[dict] = []
    license: Optional[str] = None
    job: str
    stopTime: int
    event: str
    nixName: str
    finished: bool
    timestamp: int
    jobset: str
    homepage: Optional[str] = None
    outputs: List[BuildOutput]
    build: int
    drvPath: str
    system: str
    description: Optional[str] = None
    buildStatus: int
    project: str
    startTime: int

    @property
    def successful(self) -> bool:
        return self.finished and self.buildStatus == 0


class JobsetEval(BaseModel):
    id: int
    builds: list[int]
    hasnewbuilds: bool
    jobsetevalinputs: dict
    flake: str
    timestamp: datetime
    evaltime: int
    checkouttime: int

    def get_commit(self) -> str:
        # GitHub repo
        match = re.search(r"/([0-9a-f]{40})", self.flake)
        if match:
            return match[1]
        # Generic git repo
        match = re.search(r"rev=([0-9a-f]{40})", self.flake)
        if match:
            return match[1]
        raise RuntimeError(f"Did not find commit in {self.flake=}")


class JobsetEvals(BaseModel):
    evals: list[JobsetEval]

    def find_by_build_id(self, build_id: int) -> JobsetEval:
        for e in self.evals:
            if build_id in e.builds:
                return e
        raise RuntimeError(f"Did not find {build_id=} in jobset")

    @classmethod
    def from_api(cls, project: str, jobset: str) -> Self:
        r = requests.get(
            f"{HYDRA_URL}/jobset/{project}/{jobset}/evals",
            headers={"Accept": "application/json"},
        )
        r.raise_for_status()
        return cls.model_validate_json(r.text)


class Build(BaseModel):
    project: str
    nixname: str
    job: str
    buildstatus: int | None = None
    starttime: datetime | None = None
    system: str
    priority: int
    stoptime: int | None = None
    drvpath: str
    jobsetevals: list[int]
    id: int
    jobset: str
    finished: bool

    @property
    def successful(self) -> bool:
        return self.finished and self.buildstatus == 0

    @classmethod
    def from_id(cls, build_id: int) -> Self:
        r = requests.get(
            f"{HYDRA_URL}/build/{build_id}", headers={"Accept": "application/json"}
        )
        r.raise_for_status()
        return cls.model_validate_json(r.text)


def git_set_branch_to_commit(git_url: str, branch_name: str, commit_id: str):
    with open("/run/agenix/nix-access-token") as f:
        match = re.search(r"(ghp_[0-9a-zA-Z]+)", f.read())
        if not match:
            raise ValueError("Cannot get GitHub access token")
        github_token = match[1]

    # Inject GitHub access token
    git_url = git_url.replace(
        "https://github.com/", f"https://api:{github_token}@github.com/"
    )

    with tempfile.TemporaryDirectory(prefix="hydra-post-build-") as d:
        logging.info(f"Temp dir: {d}")
        subprocess.run(["git", "clone", git_url, d], check=True)
        try:
            subprocess.run(["git", "checkout", branch_name], check=True, cwd=d)
        except subprocess.CalledProcessError:
            subprocess.run(["git", "checkout", "-b", branch_name], check=True, cwd=d)
        subprocess.run(["git", "reset", "--hard", commit_id], check=True, cwd=d)
        subprocess.run(
            ["git", "push", "-u", "origin", branch_name, "--force"], check=True, cwd=d
        )


if __name__ == "__main__":
    with open(sys.argv[1]) as f:
        event = BuildEvent.model_validate_json(f.read())

    # If nix-cachyos-kernel build is >=75% successful, update GitHub branch
    try:
        if event.project == "lantian" and event.jobset == "nix-cachyos-kernel":
            logging.info("Checking if all builds are complete")
            evals = JobsetEvals.from_api(event.project, event.jobset)
            eval = evals.find_by_build_id(event.build)
            commit_id = eval.get_commit()
            logging.info(f"{eval.id=} {commit_id=}")
            builds = [Build.from_id(i) for i in eval.builds]

            all_complete = all(b.finished for b in builds)
            pass_count = len([b for b in builds if b.successful])
            pass_rate = pass_count / len(builds)
            logging.info(f"{all_complete=} {pass_rate=}")

            if all_complete and pass_rate >= 0.75:
                git_set_branch_to_commit(
                    "https://github.com/xddxdd/nix-cachyos-kernel.git",
                    "release",
                    commit_id,
                )
    except Exception as e:
        logging.exception(f"Error in kernel build processing")

    # If build is successful, trigger attic for output paths
    try:
        if event.successful:
            output_paths = [o.path for o in event.outputs]
            subprocess.run(["attic", "push", "lantian", *output_paths], check=False)
    except Exception:
        logging.exception(f"Error in attic push")
