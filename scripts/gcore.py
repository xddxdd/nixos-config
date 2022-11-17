import json
import requests
import sys
from urllib.parse import urlparse

assert len(sys.argv) == 3

UPTIMEROBOT_KEY = sys.argv[1]
with open(sys.argv[2]) as f:
    RECORDS = json.load(f)

def get_uptimerobot_status():
    d = {}

    def _get(offset):
        result = requests.post('https://api.uptimerobot.com/v2/getMonitors', {
            "api_key": UPTIMEROBOT_KEY,
            "format": "json",
            "types": "1",
            "offset": offset,
        }).json()

        for rec in result['monitors']:
            d[urlparse(rec['url']).hostname] = rec['status'] == 2

        return result

    result = _get(0)
    while result["pagination"]["offset"] + result["pagination"]["limit"] < result["pagination"]["total"]:
        result = _get(result["pagination"]["offset"] + result["pagination"]["limit"])

    return d

STATUS = get_uptimerobot_status()

def get_host_record(type):
    return lambda host: [{
        "content": [v],
        "enabled": STATUS[host['name']] if host['name'] in STATUS else False,
        "meta": {
            "latlong": [
                float(host['lat']),
                float(host['lng']),
            ],
        },
    } for v in host[type]]

def dump_gcore_rrset(file, fn):
    rrs = []
    for r in RECORDS:
        rrs.extend(fn(r))

    return json.dump({
        "ttl": 60,
        "filters": [
            {
                "type": "geodistance",
                "strict": False
            },
            {
                "type": "first_n",
                "limit": 1,
                "strict": False
            },
        ],
        "resource_records": rrs,
    }, file)

dump_gcore_rrset(open('a.json', 'w'), get_host_record("A"))
dump_gcore_rrset(open('aaaa.json', 'w'), get_host_record("AAAA"))
dump_gcore_rrset(open('cname.json', 'w'), get_host_record("CNAME"))
