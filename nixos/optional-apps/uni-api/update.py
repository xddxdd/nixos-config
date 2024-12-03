import json
import multiprocessing
import os
import pathlib
import subprocess
import sys
import urllib.request
from typing import Dict, List, Optional, Tuple

SCRIPT_PATH = os.path.dirname(os.path.realpath(sys.argv[0]))
SECRET_BASE = os.environ["SECRET_BASE"]
HOME = pathlib.Path.home()

APIS = {
    "groq": "https://api.groq.com/openai/v1",
    "mistral": "https://api.mistral.ai/v1",
    "openrouter": "https://openrouter.ai/api/v1",
    "siliconflow": "https://api.siliconflow.cn/v1",
    "novita": "https://api.novita.ai/v3/openai",
}

GUESS_PROVIDER_PREFIX_MAP = {
    "mistralai": [
        "codestral-",
        "ministral-",
        "mistral-",
        "mixtral-",
        "open-codestral-",
        "open-mistral-",
        "open-mixtral-",
        "pixtral-",
    ],
    "meta-llama": ["llama-"],
    "google": ["gemma"],
}


def get_models(api_name: str, base_url: str) -> List[str]:
    secret = subprocess.check_output(
        [
            "nix",
            "run",
            "nixpkgs#age",
            "--",
            "-i",
            f"{HOME}/.ssh/id_ed25519",
            "-d",
            f"{SECRET_BASE}/uni-api/{api_name}-api-key.age",
        ],
        text=True,
    ).strip()

    r = urllib.request.Request(
        f"{base_url}/models",
        method="GET",
        headers={
            "User-Agent": "lantian",
            "Authorization": f"Bearer {secret}",
        },
    )
    content = urllib.request.urlopen(r).read()

    models = json.loads(content)
    model_ids: List[str] = [m["id"] for m in models["data"]]
    return model_ids


def guess_provider(model_id: str) -> Optional[str]:
    for provider, prefixes in GUESS_PROVIDER_PREFIX_MAP.items():
        for prefix in prefixes:
            if model_id.startswith(prefix):
                return provider
    return None


def normalize_model_id(api_name: str, model_id: str) -> str:
    # Enforce lowercase for model name
    result = model_id.lower()

    # Guess provider for model
    if "/" not in result:
        provider = guess_provider(result)
        if not provider:
            provider = f"@{api_name}"
        result = f"{provider}/{result}"

    # Remove Pro/ prefix for SiliconFlow
    if result.startswith("pro/"):
        result = f"{result[4:]}:pro"

    return result


def create_mappings(api_name: str, model_ids: List[str]) -> Dict[str, str]:
    return {m: normalize_model_id(api_name, m) for m in model_ids}


def process_api(input_obj: Tuple[str, str]):
    api_name, base_url = input_obj
    models = get_models(api_name, base_url)
    mappings = create_mappings(api_name, models)
    with open(f"{SCRIPT_PATH}/apis/{api_name}.json", "w") as f:
        json.dump(mappings, f, indent=2, sort_keys=True)
        f.write("\n")


if __name__ == "__main__":
    os.makedirs(f"{SCRIPT_PATH}/apis", exist_ok=True)
    pool = multiprocessing.Pool()
    pool.map(process_api, APIS.items())
