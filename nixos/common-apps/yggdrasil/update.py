import json
import os
import sys
from typing import Dict, List

import requests
from bs4 import BeautifulSoup

SCRIPT_PATH = os.path.dirname(os.path.realpath(sys.argv[0]))

r = requests.get("https://publicpeers.neilalexander.dev/")
soup = BeautifulSoup(r.text, features="html.parser")

servers: Dict[str, List[str]] = {}
current_country = ""

for row in soup.table.children:
    if row.name == "thead":
        country_elem = row.find(id="country")
        current_country = country_elem.text
    elif row.name == "tbody":
        for server_row in row.find_all(class_="statusgood"):
            address: str = server_row.find(id="address").text
            if not address.startswith("tls://"):
                continue
            if current_country not in servers:
                servers[current_country] = []
            servers[current_country].append(address)
            servers[current_country].sort()

with open(os.path.join(SCRIPT_PATH, "public-peers.json"), "w") as f:
    json.dump(servers, f, indent=2, sort_keys=True)
    f.write("\n")
