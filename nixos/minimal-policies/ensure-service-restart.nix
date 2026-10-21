{ config, lib, ... }:
let
  ignored = [
    # keep-sorted start
    "acpid"
    "bluetooth"
    "enable-ksm"
    "hydra-send-stats"
    "openvpn-restart"
    "polkit"
    "reload-systemd-vconsole-setup"
    "rtkit-daemon"
    # keep-sorted end
  ];

  # Systemd default RestartSec is 100ms, too short to pass the 5-restarts-per-10s start rate limit.
  # Parse RestartSec value into seconds; null when missing or unparseable.
  parseTimeToSec =
    v:
    let
      multSec = {
        us = 0.000001;
        ms = 0.001;
        s = 1.0;
        sec = 1.0;
        secs = 1.0;
        m = 60.0;
        min = 60.0;
        mins = 60.0;
        h = 3600.0;
        hr = 3600.0;
        hrs = 3600.0;
      };
    in
    if v == null then
      null
    else if builtins.isInt v then
      v
    else if builtins.isString v then
      let
        m = builtins.match "([0-9]*\\.?[0-9]+)(us|ms|secs|sec|mins|min|hrs|hr|s|m)" v;
        numValue = builtins.tryEval (builtins.fromJSON (if m == null then "0" else builtins.elemAt m 0));
        plainValue = builtins.tryEval (builtins.fromJSON v);
      in
      if m != null && numValue.success then
        numValue.value * multSec."${builtins.elemAt m 1}"
      else if plainValue.success then
        plainValue.value
      else
        null
    else
      null;

  hasRestart =
    n: v:
    # Check restart setting
    (v.serviceConfig.Restart or "") != ""
    # Ignore services explicitly set as ignored
    || builtins.elem n ignored
    # Ignore services with at sign
    || lib.hasInfix "@" n
    # Ignore services part of sockets
    || builtins.elem n (builtins.attrNames config.systemd.sockets)
    # Ignore services part of timers
    || builtins.elem n (builtins.attrNames config.systemd.timers)
    # Ignore disabled services
    || !(v.enable or true)
    # Ignore services without ExecStart (might be managed externally)
    || ((v.serviceConfig.ExecStart or "") == "")
    # Ignore oneshot or dbus activated services
    || (builtins.elem (v.serviceConfig.Type or "") [
      "oneshot"
      "dbus"
    ]);

  servicesWithRestart = lib.filterAttrs hasRestart config.systemd.services;
  restartUnsetOrDisabled =
    n: v:
    (v.serviceConfig.Restart or "") == ""
    || (v.serviceConfig.Restart or "") == "no"
    || !(v.enable or true)
    || builtins.elem (v.serviceConfig.Type or "") [
      "oneshot"
      "dbus"
    ];

  requiredByServicesWithRestart = lib.flatten (
    lib.mapAttrsToList (n: v: (v.requires or [ ]) ++ (v.wants or [ ])) servicesWithRestart
  );
  requiresServicesWithRestart = builtins.attrNames (
    lib.filterAttrs (
      n: v:
      ((lib.intersectLists (v.requiredBy or [ ]) (builtins.attrNames servicesWithRestart)) != [ ])
      || ((lib.intersectLists (v.wantedBy or [ ]) (builtins.attrNames servicesWithRestart)) != [ ])
    ) config.systemd.services
  );

  restartDisabledOrOk =
    n: v:
    restartUnsetOrDisabled n v
    || (
      let
        s = parseTimeToSec (v.serviceConfig.RestartSec or null);
      in
      s != null && s >= 3
    );
in
{
  assertions =
    (lib.mapAttrsToList (n: v: {
      assertion =
        hasRestart n v
        || builtins.elem "${n}.service" requiredByServicesWithRestart
        || builtins.elem n requiresServicesWithRestart;
      message = "${n} does not have Restart attribute set";
    }) config.systemd.services)
    ++ (lib.mapAttrsToList (n: v: {
      assertion = restartDisabledOrOk n v;
      message = "${n} has RestartSec below 3s or unparseable (systemd default throttling limit is 5 restarts per 10s)";
    }) config.systemd.services);

  # Upstream nixos/modules/services/system/nscd.nix sets Restart but not RestartSec,
  # which would fail the assertion above
  systemd.services.nscd.serviceConfig.RestartSec = "5s";

}
