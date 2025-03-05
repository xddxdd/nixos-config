import json
import os
import time

import requests

flaresolverr_url = os.environ["FLARESOLVERR_URL"]
username = os.environ["HDTIME_USER"]
password = os.environ["HDTIME_PASS"]

try:
    with open("hdtime.json") as f:
        j = json.load(f)
        if j["expiry"] <= int(time.time()):
            raise ValueError("Cookie expired")
        print(j["value"])
        exit(0)
except Exception as e:
    pass

# Login
q = requests.post(
    f"{flaresolverr_url}/v1",
    headers={
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36"
    },
    json={
        "cmd": "request.post",
        "url": "https://hdtime.org/takelogin.php",
        "postData": f"username={username}&password={password}&trackerssl=yes",
    },
)
j = q.json()

cookies = j.get("solution", {}).get("cookies", [])
if not cookies:
    raise ValueError("Did not receive any cookies")
expiry = min([c.get("expiry", time.time()) for c in cookies])
if expiry <= int(time.time()):
    raise ValueError("Got expired cookie from fresh request")
cookie_str = "; ".join([c["name"] + "=" + c["value"] for c in cookies])
print(cookie_str)

with open("hdtime.json", "w") as f:
    json.dump({"expiry": expiry, "value": cookie_str}, f)
