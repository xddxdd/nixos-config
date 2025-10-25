#!/usr/bin/env python

import json
import os
import subprocess

import requests

UPTIMEROBOT_API_KEY = os.environ.get("UPTIMEROBOT_API_KEY")
UPTIMEROBOT_API_BASE_URL = "https://api.uptimerobot.com/v3"

if not UPTIMEROBOT_API_KEY:
    raise Exception("UPTIMEROBOT_API_KEY 环境变量未设置。")


def call_uptimerobot_api(method, endpoint, payload=None, monitor_id=None):
    headers = {
        "Content-Type": "application/json",
        "cache-control": "no-cache",
        "Authorization": f"Bearer {UPTIMEROBOT_API_KEY}",
    }
    url = f"{UPTIMEROBOT_API_BASE_URL}{endpoint}"
    if monitor_id:
        url = f"{url}/{monitor_id}"

    if method == "GET":
        response = requests.get(url, headers=headers, params=payload)
    elif method == "POST":
        response = requests.post(url, headers=headers, json=payload)
    elif method == "PATCH":
        response = requests.patch(url, headers=headers, json=payload)
    elif method == "DELETE":
        response = requests.delete(url, headers=headers, json=payload)
    else:
        raise ValueError(f"不支持的 HTTP 方法: {method}")

    response.raise_for_status()
    if method == "DELETE" and not response.content:
        return None
    return response.json()


def get_monitors():
    return call_uptimerobot_api("GET", "/monitors")


def new_monitor(friendly_name, url):
    payload = {
        "friendlyName": friendly_name,
        "url": url,
        "type": "HTTP",
        "interval": 300,
        "timeout": 30,
        "httpMethodType": "GET",
        "gracePeriod": 0,
    }
    return call_uptimerobot_api("POST", "/monitors", payload=payload)


def delete_monitor(monitor_id):
    return call_uptimerobot_api("DELETE", "/monitors", monitor_id=monitor_id)


def edit_monitor(monitor_id, friendly_name, url):
    payload = {
        "friendlyName": friendly_name,
        "url": url,
        "type": "HTTP",
        "interval": 300,
        "timeout": 30,
        "httpMethodType": "GET",
        "gracePeriod": 0,
    }
    return call_uptimerobot_api(
        "PATCH", "/monitors", payload=payload, monitor_id=monitor_id
    )


def main():
    print("正在获取主机名列表...")
    current_dir = os.getcwd()
    nix_command = [
        "nix",
        "eval",
        "--json",
        "--impure",
        "--expr",
        f'with builtins.getFlake "path:{current_dir}"; builtins.attrNames (LT.hostsWithTag LT.tags.public-facing)',
    ]
    result = subprocess.run(nix_command, capture_output=True, text=True, check=True)
    host_names = json.loads(result.stdout)
    print(f"已获取 {len(host_names)} 个主机名: {host_names}")

    print("正在获取现有的 UptimeRobot 监控器...")
    existing_monitors_response = get_monitors()
    existing_monitors = {}
    if (
        existing_monitors_response
        and existing_monitors_response.get("data") is not None
    ):
        for monitor in existing_monitors_response.get("data", []):
            existing_monitors[monitor["friendlyName"]] = monitor
        print(f"已获取 {len(existing_monitors)} 个现有监控器。")
    else:
        raise Exception("获取现有监控器失败或没有监控器。")

    print("正在创建或更新监控器...")
    for host in host_names:
        monitor_name = f"Blog/{host}"
        monitor_target_url = f"https://{host}.lantian.pub"

        if monitor_name in existing_monitors:
            monitor = existing_monitors[monitor_name]
            if monitor["url"] != monitor_target_url:
                print(
                    f"正在更新监控器 '{monitor_name}' (ID: {monitor['id']})，URL 从 '{monitor['url']}' 更改为 '{monitor_target_url}'..."
                )
                truncated_monitor_name = monitor_name[:100]
                edit_monitor(monitor["id"], truncated_monitor_name, monitor_target_url)
                print(f"监控器 '{monitor_name}' 已更新。")
            else:
                print(f"监控器 '{monitor_name}' 已存在且 URL 正确。")
            del existing_monitors[monitor_name]
        else:
            print(
                f"正在创建新监控器 '{monitor_name}'，目标 URL: '{monitor_target_url}'..."
            )
            truncated_monitor_name = monitor_name[:100]
            new_monitor(truncated_monitor_name, monitor_target_url)
            print(f"监控器 '{monitor_name}' 已创建。")

    print("正在删除不再存在的主机的监控器...")
    for monitor_name, monitor in existing_monitors.items():
        if monitor_name.startswith("Blog/"):
            print(f"正在删除不再需要监控器 '{monitor_name}' (ID: {monitor['id']})...")
            delete_monitor(monitor["id"])
            print(f"监控器 '{monitor_name}' 已删除。")

    print("同步完成。")


if __name__ == "__main__":
    main()
