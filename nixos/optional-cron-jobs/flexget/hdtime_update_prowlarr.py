import os

import requests

prowlarr_url = os.environ["PROWLARR_URL"]
prowlarr_apikey = os.environ["PROWLARR_APIKEY"]
hdtime_cookie = os.environ["HDTIME_COOKIE"]

if not hdtime_cookie:
    print("No HDTime cookie found")
    exit(1)

print("Listing indexers")
indexers = requests.get(
    f"{prowlarr_url}/api/v1/indexer",
    headers={
        "X-Api-Key": prowlarr_apikey,
    },
).json()

for indexer in indexers:
    if indexer.get("definitionName") != "hdtime":
        continue
    if not indexer.get("fields"):
        continue
    indexer_id = indexer.get("id")
    if indexer_id is None:
        continue

    print(f"Updating HDTime indexer with ID {indexer_id}")

    for i in range(len(indexer["fields"])):
        if indexer["fields"][i]["name"] != "cookie":
            continue

        if indexer["fields"][i]["value"] == hdtime_cookie:
            print("Cookie is up to date")
            exit(0)
        indexer["fields"][i]["value"] = hdtime_cookie

        print("Updating cookie")
        response = requests.put(
            f"{prowlarr_url}/api/v1/indexer/{indexer_id}",
            headers={
                "X-Api-Key": prowlarr_apikey,
            },
            json=indexer,
        )
        print(f"Prowlarr API returned {response.status_code}")
        exit(0)
