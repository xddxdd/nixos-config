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
in
{
  assertions = lib.mapAttrsToList (n: v: {
    assertion =
      hasRestart n v
      || builtins.elem "${n}.service" requiredByServicesWithRestart
      || builtins.elem n requiresServicesWithRestart;
    message = "${n} does not have Restart attribute set";
  }) config.systemd.services;
}
