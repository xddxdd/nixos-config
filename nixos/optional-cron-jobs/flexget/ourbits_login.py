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

print("ourbits_jwt cookie not found")
exit(1)
