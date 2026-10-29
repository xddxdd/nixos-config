---
name: fleet-crash-loop-check
description: Log in to every fleet host over SSH and check recent logs for systemd services stuck in a restart crash loop (repeated "Scheduled restart job" events) or in failed state. Use when the user asks to check fleet/service health, find crash loops, restart storms, or failed units across the NixOS fleet.
disable-model-invocation: false
---

# Fleet crash-loop check

## Fleet facts

- Host list is generated live from the flake's `LT.hosts`: `root@<hostname-field>` on port 2222 (SSH user/port per `nixos/minimal-components/colmena-deployment.nix`). No static inventory file is kept.
- `lt-hp-omen` is the local laptop (`127.0.0.1`). `manualDeploy=true` hosts (`lt-home-router`, `pve-c3758`, `pve-hp-z220-sff`) still exist and are checked like any other host.
- Detection principle (verified against real journald output): every auto-restart makes systemd log `*.service: Scheduled restart job, restart counter is at N.`; many such events for one unit in the window means a restart loop.

## Workflow

1. Generate the host list from the flake and run the sweep (read-only; window defaults to 24h):

   ```bash
   nix eval --impure --json --expr '
   let
     f = builtins.getFlake "path:/home/lantian/Projects/nixos-config";
     inherit (f.inputs.nixpkgs) lib;
     LT = import /home/lantian/Projects/nixos-config/helpers {
       pkgs = f.inputs.nixpkgs; inherit (f) inputs; inherit (f.inputs.nixpkgs) lib; self = f;
     };
   in lib.mapAttrsToList (n: h: "${n} ${h.hostname} ${toString h.sshPort}") LT.hosts' \
     | jq -r '.[]' | bash scripts/check.sh [window]
   ```

   Window is journalctl-relative time (e.g. `10min`, `2h`, `24h`; default `24h`). Output is grouped per host: `-- failed --` units and `-- restart events --` counts. `SSH FAILED` means unreachable — report it, do not retry indefinitely.

2. Interpret the sweep output:
   - A unit with **many restart events** in the window (typically ≥3) is a likely crash loop. Single events (counter 1) are normal restarts after config changes — not loops.   - Failed units that are disabled/inactive leftovers are noise; check their state before calling them broken.
3. For each suspected crash loop, deep-dive (read-only):

   ```bash
   ssh -p 2222 root@<host> journalctl -u <unit>.service --since=-24h -n 80 --no-pager
   ssh -p 2222 root@<host> systemctl show <unit> -p Result -p RestartCount -p SubState -p NRestarts
   ```

   Report the repeating error text from the journal, not just the restart counts.

4. Report per host: offender units, crash-loop judgment (yes/no + evidence), failed units, reachability. Fix decisions stay with the user; this skill only observes.

## Constraints

- Read-only probes only (systemctl show/list-units, journalctl). Never mutate remote state from this skill — fleet changes must go through the flake.
- If a host is unreachable, say so explicitly alongside the findings from the reachable hosts.