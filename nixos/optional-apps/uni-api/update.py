import json
import multiprocessing
import os
import pathlib
import re
import subprocess
import sys
import urllib.request
from typing import Dict, List, Optional, Tuple

SCRIPT_PATH = os.path.dirname(os.path.realpath(sys.argv[0]))
SECRET_BASE = os.environ["SECRET_BASE"]
HOME = pathlib.Path.home()
USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36"

APIS = {
    "ai-985-games": "https://ai.985.games/v1",
    "cloudflare": "__CLOUDFLARE__",
    "groq": "https://api.groq.com/openai/v1",
    "google": "__GOOGLE__",
    "lingyiwanwu": "https://api.lingyiwanwu.com/v1",
    "mistral": "https://api.mistral.ai/v1",
    "novita": "https://api.novita.ai/v3/openai",
    "openrouter": "https://openrouter.ai/api/v1",
    "siliconflow": "https://api.siliconflow.cn/v1",
    "smnet-free-chat": "https://api-1-hemf.onrender.com/v1",
    "xai": "https://api.x.ai/v1",
}

GUESS_PROVIDER_PREFIX_MAP = {
    "mistralai": [
        "codestral",
        "ministral",
        "mistral",
        "mixtral",
        "open-codestral",
        "open-mistral",
        "open-mixtral",
        "pixtral",
    ],
    "meta-llama": ["llama"],
    "google": [
        "gemini",
        "gemma",
    ],
    "01-ai": ["yi"],
    "thudm": [
        "glm",
        "chatglm",
    ],
    "tencent": ["hunyuan"],
    "internlm": ["internlm"],
    "qwen": [
        "qwen",
        "qwq",
    ],
    "openai": [
        "gpt",
        "o1",
        "o3",
    ],
    "deepseek": ["deepseek"],
    "anthropic": ["claude"],
    "x-ai": ["grok"],
    "cohere": ["command-r"],
}

NORMALIZE_PROVIDER_PREFIX_MAP = {
    "deepseek": ["deepseek-ai"],
}


def get_api_secret(api_name: str) -> str:
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
    return secret


def get_models_google(api_name: str) -> List[str]:
    secret = get_api_secret(api_name)

    r = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models?key={secret}",
        method="GET",
        headers={
            "User-Agent": USER_AGENT,
        },
    )
    content = urllib.request.urlopen(r).read()

    models = json.loads(content)
    # Remove "models/" prefix
    # uni-api only supports Gemini models
    return [m["name"][7:] for m in models["models"] if "models/gemini" in m["name"]]


def get_models_cloudflare(api_name: str) -> List[str]:
    try:
        r = urllib.request.Request(
            f"https://playground.ai.cloudflare.com/api/models",
            method="GET",
            headers={
                "User-Agent": USER_AGENT,
            },
        )
        content = urllib.request.urlopen(r).read()
        models = json.loads(content)
        with open(
            os.path.join(os.path.dirname(__file__), "models_json/cloudflare.json"), "w"
        ) as f:
            json.dump(models, f)
    except Exception as e:
        print(f"Error with get Cloudflare models, using cached models: {e}")

    with open(
        os.path.join(os.path.dirname(__file__), "models_json/cloudflare.json")
    ) as f:
        models = json.load(f)
    return [m["name"] for m in models["models"]]


def get_models_local(api_name: str) -> List[str]:
    path = os.path.join(os.path.dirname(__file__), f"models_json/{api_name}.txt")
    if os.path.exists(path):
        with open(path) as f:
            return [s.strip() for s in f.readlines() if s.strip() != ""]
    raise ValueError(f"No local model info found for {api_name}")


def get_models(api_name: str, base_url: str) -> List[str]:
    if base_url == "__CLOUDFLARE__":
        return get_models_cloudflare(api_name)
    if base_url == "__GOOGLE__":
        return get_models_google(api_name)
    if base_url == "__LOCAL__":
        return get_models_local(api_name)

    secret = get_api_secret(api_name)

    r = urllib.request.Request(
        f"{base_url}/models",
        method="GET",
        headers={
            "User-Agent": USER_AGENT,
            "Authorization": f"Bearer {secret}",
        },
    )
    content = urllib.request.urlopen(r).read()

    models = json.loads(content)
    if "data" in models:
        model_ids: List[str] = [m["id"] for m in models["data"]]
    else:
        raise ValueError(f"No model info found in {models}")

    return model_ids


def guess_provider(model_id: str) -> Optional[str]:
    for provider, prefixes in GUESS_PROVIDER_PREFIX_MAP.items():
        for prefix in prefixes:
            if model_id.startswith(prefix):
                return provider
    return None


def normalize_model_id(api_name: str, model_id: str) -> str:
    # Enforce lowercase for model name
    base = model_id.lower()
    suffix = ""

    # Remove provider's own differentiator in model prefix
    base = re.sub(r"^@[^/]+/", "", base)

    # Move extra prefix to the end as model variants
    if base.count("/") > 1:
        splitted = base.split("/")
        suffix = "/".join(splitted[:-2])
        base = f"{splitted[-2]}/{splitted[-1]}"

    # Add separator between model name and version
    base = re.sub(r"(^|/)([a-zA-Z]{2,})([0-9]+)([^/]*)$", r"\1\2-\3\4", base)

    # Guess provider for model
    if "/" in base:
        provider = base.split("/")[0]
        base = base.split("/")[1]
        for normalized, providers in NORMALIZE_PROVIDER_PREFIX_MAP.items():
            if provider in providers:
                provider = normalized
        base = f"{provider}/{base}"
    else:
        provider = guess_provider(base)
        if provider:
            base = f"{provider}/{base}"

    return base


def create_mappings(api_name: str, model_ids: List[str]) -> Dict[str, str]:
    return {m: normalize_model_id(api_name, m) for m in model_ids}


def process_api(input_obj: Tuple[str, str]):
    try:
        api_name, base_url = input_obj
        models = get_models(api_name, base_url)
        mappings = create_mappings(api_name, models)
        with open(f"{SCRIPT_PATH}/apis/{api_name}.json", "w") as f:
            json.dump(mappings, f, indent=2, sort_keys=True)
            f.write("\n")
        return True
    except Exception as e:
        print(f"Error with {api_name}: {e}")


if __name__ == "__main__":
    os.makedirs(f"{SCRIPT_PATH}/apis", exist_ok=True)
    pool = multiprocessing.Pool()
    try:
        pool.map(process_api, APIS.items())
    except Exception as e:
        print(e)
