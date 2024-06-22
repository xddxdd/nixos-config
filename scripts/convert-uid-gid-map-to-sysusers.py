import json
import subprocess

with open("/var/lib/nixos/uid-map") as f:
    uid_map: dict = json.load(f)

subprocess.run(["mkdir", "-p", "/var/lib/nixos/uid"], check=True)

for user, uid in uid_map.items():
    subprocess.run(["touch", f"/var/lib/nixos/uid/{user}"], check=True)
    subprocess.run(["chown", f"{uid}:0", f"/var/lib/nixos/uid/{user}"], check=True)


with open("/var/lib/nixos/gid-map") as f:
    gid_map = json.load(f)

subprocess.run(["mkdir", "-p", "/var/lib/nixos/gid"], check=True)

for group, gid in gid_map.items():
    subprocess.run(["touch", f"/var/lib/nixos/gid/{group}"], check=True)
    subprocess.run(["chown", f"0:{gid}", f"/var/lib/nixos/gid/{group}"], check=True)
