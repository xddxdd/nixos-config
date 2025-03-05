import json
import os
import time

import requests

flaresolverr_url = os.environ["FLARESOLVERR_URL"]
username = os.environ["OURBITS_USER"]
password = os.environ["OURBITS_PASS"]

try:
    with open("ourbits.json") as f:
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
        "url": "https://ourbits.club/takelogin.php",
        "postData": f"username={username}&password={password}&trackerssl=yes",
    },
)
j = q.json()
for cookie in j.get("solution", {}).get("cookies", []):
    if cookie.get("name") != "ourbits_jwt":
        continue

    expiry = cookie.get("expiry")
    if expiry <= int(time.time()):
        raise ValueError("Got expired cookie from fresh request")

    value = cookie.get("value")
    if value:
        print(value)
        with open("ourbits.json", "w") as f:
            json.dump(cookie, f)
        exit(0)

exit(1)
