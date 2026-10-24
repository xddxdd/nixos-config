#!/usr/bin/env python3
import os

import requests

BASE_URL = os.environ["BASE_URL"]
USERNAME = os.environ["USERNAME"]
PASSWORD = os.environ["PASSWORD"]

session = requests.Session()
headers = {
    "Content-Type": "application/json",
    "Referer": BASE_URL + "/",
    "Accept": "application/json",
}

# 登录获取 cookie
login_resp = session.post(
    f"{BASE_URL}/login",
    json={"username": USERNAME, "password": PASSWORD},
    headers=headers,
    allow_redirects=False,
)

if login_resp.status_code not in (200, 302, 303):
    print(f"登录失败: {login_resp.status_code}")
    print(login_resp.text)
    exit(1)

# 调用 clear-queue-non-current
result = session.post(f"{BASE_URL}/admin/clear-queue-non-current", headers=headers)
print(f"状态码: {result.status_code}")
print(result.text)
