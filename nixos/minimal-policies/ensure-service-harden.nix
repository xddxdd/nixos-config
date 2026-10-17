{
  config,
  lib,
  ...
}:
let
  # Only key presence is checked: values may be overridden for legit reasons,
  # so any explicit value satisfies the assertion. Keys are imported from the
  # same file as LT.serviceHarden (same key set as LT.networkToolHarden).
  # Imported directly instead of via LT to track the raw args without the
  # mkOptionDefault wrappers.
  requiredKeys = builtins.attrNames (
    (import ../../helpers/fn/service-harden.nix { inherit lib; }).serviceHardenArgs
  );

  # Services legitimately needing full/hardware access: PVE cluster daemons,
  # sshd, OVS, hardware monitors, upstream system services
  ignored = [
    # keep-sorted start
    "acpid"
    "bluetooth"
    "corosync"
    "cups-browsed"
    "enable-ksm"
    "greetd"
    "nvidia-persistenced"
    "ovs-vswitchd"
    "ovsdb"
    "pcscd"
    "polkit"
    "pve-cluster"
    "pvedaemon"
    "pveproxy"
    "pvescheduler"
    "pvestatd"
    "qmeventd"
    "reload-systemd-vconsole-setup"
    "rrdcached"
    "rtkit-daemon"
    "spiceproxy"
    "sshd"
    "usbmuxd"
    # keep-sorted end
  ];

  # Core system services provided by systemd/NixOS itself, not application
  # services; anything starting with "systemd" is covered too
  coreServiceNames = [
    # keep-sorted start
    "dbus"
    "nix-daemon"
    "nix-gc"
    "nix-optimise"
    "nscd"
    # keep-sorted end
  ];

  isCoreService = n: lib.hasPrefix "systemd" n || builtins.elem n coreServiceNames;

  exempt =
    n: v:
    builtins.elem n ignored
    # Template definitions are hardening-independent; instances are checked by
    # name in ensure-service-restart.nix
    || lib.hasInfix "@" n
    # Disabled services
    || !(v.enable or true)
    # Services without ExecStart may be managed externally
    || ((v.serviceConfig.ExecStart or "") == "")
    # Oneshot and dbus-activated services
    || (builtins.elem (v.serviceConfig.Type or "") [
      "oneshot"
      "dbus"
    ])
    # Core system services
    || isCoreService n;

  # builtins.hasAttr instead of the `?` operator: on Nix 2.35, `set ? var`
  # with a variable key always returns false (broken dynamic attrpath check),
  # which would flag fully hardened services as missing everything
  missingKeys =
    n: v:
    lib.filter (k: !builtins.hasAttr k v.serviceConfig) requiredKeys;
in
{
  assertions = lib.mapAttrsToList (
    n: v:
    let
      missing = missingKeys n v;
    in
    {
      assertion = exempt n v || missing == [ ];
      message = "${n} is missing systemd service hardening options (LT.serviceHarden): ${
        lib.concatStringsSep ", " missing
      }";
    }
  ) config.systemd.services;
}