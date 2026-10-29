#!/bin/bash
# Usage: fleets <name host port>... over stdin | check.sh [window]
# Window in journalctl format, e.g. 10min, 2h, 24h (default: 24h)
WIN="${1:-24h}"

while read -r name host port; do
  (
    out=$(ssh -p "$port" -o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new \
      "root@$host" bash -s -- "$WIN" <<'EOF'
WIN=$1
echo "-- failed --"
systemctl list-units --type=service --state=failed --no-legend --no-pager
echo "-- restart events in last ${WIN} (count unit) --"
journalctl --system --since="-$WIN" --no-pager --grep 'restart counter is at' -o cat \
  | awk '{u=$1; sub(/:$/,"",u); print u}' | sort | uniq -c | sort -rn
EOF
    ) || out="SSH FAILED"
    echo "== $name ($host:$port) =="
    echo "$out"
  ) &
done
wait