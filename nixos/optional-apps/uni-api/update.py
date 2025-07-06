#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p age
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
    "akash-networks": "https://chatapi.akash.network/api/v1",
    "cerebras": "https://api.cerebras.ai/v1",
    "chutes-ai": "https://llm.chutes.ai/v1",
    "cloudflare": "__CLOUDFLARE__",
    "github-models": "__GITHUB_MODELS__",
    "google": "__GOOGLE__",
    "groq": "https://api.groq.com/openai/v1",
    "lingyiwanwu": "https://api.lingyiwanwu.com/v1",
    "mistral": "https://api.mistral.ai/v1",
    "modelscope": "https://api-inference.modelscope.cn/v1",
    "nvidia": "https://integrate.api.nvidia.com/v1",
    "openrouter": "https://openrouter.ai/api/v1",
    "pollinations": "https://text.pollinations.ai/openai",
    "siliconflow": "https://api.siliconflow.cn/v1",
    "wbot": "https://api.223387.xyz/v1",
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
        "codeqwen",
    ],
    "openai": [
        "gpt",
        "o1",
        "o3",
        "text-embedding-3",
        "whisper",
    ],
    "deepseek": ["deepseek"],
    "anthropic": ["claude"],
    "x-ai": ["grok"],
    "cohere": ["command-r"],
    "microsoft": ["phi"],
    "baichuan": ["baichuan"],
    "bytedance": ["doubao"],
    "baidu": ["ernie"],
    "moonshotai": ["moonshot"],
    "360ai": ["360gpt"],
}

NORMALIZE_PROVIDER_PREFIX_MAP = {
    "ai21": ["ai21labs"],
    "baidu": ["paddlepaddle"],
    "deepseek": ["deepseek-ai"],
    "meta-llama": ["meta"],
    "minimax": ["minimaxai"],
    "mistralai": ["mistral"],
}

NORMALIZE_MODEL_PREFIX_MAP = {
    "ai21-": "ai21/",
    "baai-": "baai/",
    "cohere-": "cohere/",
    "deepseek/deepseek-chat-": "deepseek/deepseek-",
    "meta-llama-": "meta-llama/llama-",
    "meta-llama/meta-llama-": "meta-llama/llama-",
}


def get_api_secret(api_name_or_filename: str) -> Optional[str]:
    try:
        filename = (
            api_name_or_filename
            if api_name_or_filename.endswith(".age")
            else f"{api_name_or_filename}-api-key.age"
        )
        secret = subprocess.check_output(
            [
                "age",
                "-i",
                f"{HOME}/.ssh/id_ed25519",
                "-d",
                f"{SECRET_BASE}/uni-api/{filename}",
            ],
            text=True,
        ).strip()
        return secret
    except subprocess.CalledProcessError:
        return None


def get_models_github_models(api_name: str) -> List[str]:
    r = urllib.request.Request(
        f"https://models.inference.ai.azure.com/models",
        method="GET",
        headers={
            "User-Agent": USER_AGENT,
        },
    )
    content = urllib.request.urlopen(r).read()

    models = json.loads(content)
    return [m["name"] for m in models]


def get_models_google(api_name: str) -> List[str]:
    secret = get_api_secret(api_name)
    results: list[str] = []
    page_token = None
    while True:
        r = urllib.request.Request(
            f"https://generativelanguage.googleapis.com/v1beta/models?key={secret}"
            + (f"&pageToken={page_token}" if page_token else ""),
            method="GET",
            headers={
                "User-Agent": USER_AGENT,
            },
        )
        content = urllib.request.urlopen(r).read()

        page = json.loads(content)
        # Remove "models/" prefix
        # uni-api only supports Gemini models
        results.extend(
            [m["name"][7:] for m in page["models"] if "models/gemini" in m["name"]]
        )

        page_token = page.get("nextPageToken")
        if not page_token:
            break

    return results


def get_models_cloudflare(api_name: str) -> List[str]:
    account_id = get_api_secret("cloudflare-account-id.age")
    api_key = get_api_secret("cloudflare-api-key.age")

    r = urllib.request.Request(
        f"https://api.cloudflare.com/client/v4/accounts/{account_id}/ai/models/search",
        method="GET",
        headers={"Authorization": f"Bearer {api_key}"},
    )
    content = urllib.request.urlopen(r).read()

    models = json.loads(content)
    return [m["name"] for m in models["result"]]


def get_models_local(api_name: str) -> List[str]:
    path = os.path.join(os.path.dirname(__file__), f"models_json/{api_name}.txt")
    if os.path.exists(path):
        with open(path) as f:
            return [s.strip() for s in f.readlines() if s.strip() != ""]
    raise ValueError(f"No local model info found for {api_name}")


def get_models(api_name: str, base_url: str) -> List[str]:
    if base_url == "__CLOUDFLARE__":
        return get_models_cloudflare(api_name)
    if base_url == "__GITHUB_MODELS__":
        return get_models_github_models(api_name)
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
            **({"Authorization": f"Bearer {secret}"} if secret else {}),
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

    # Remove model filename extension, if any
    base = re.sub(r"(\.gguf|-(i)?q[0-9a-z]+)+$", "", base, count=0, flags=re.IGNORECASE)

    # Move extra prefix to the end as model variants
    if base.count("/") > 1:
        splitted = base.split("/")
        suffix = "/".join(splitted[:-2])
        base = f"{splitted[-2]}/{splitted[-1]}"

    # Normalize model prefix
    for k, v in NORMALIZE_MODEL_PREFIX_MAP.items():
        if base.startswith(k):
            base = base.replace(k, v, 1)
            break

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

    if suffix:
        base = f"{base}:{suffix}"

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
