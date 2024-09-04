#!/bin/sh
while true; do
    for VM in $(find /etc/pve/qemu-server/ -name \*.conf); do
        grep "^affinity: " "$VM" >/dev/null 2>/dev/null || continue
        VMFILE=$(basename "$VM")
        VMID=${VMFILE%.conf}
        VMPID=$(cat "/run/qemu-server/$VMID.pid") || continue
        echo "Set SCHED_RR for VM ${VMID} PID ${VMPID}"
        chrt --rr -a -p 1 "$VMPID"
    done
    echo "Wait 10s for next cycle..."
    sleep 10
done
