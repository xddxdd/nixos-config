{
  config,
  lib,
  serviceHardenArgs,
  ...
}:
let
  # Only key presence is checked: values may be overridden for legit reasons,
  # so any explicit value satisfies the assertion. Both lantian.harden presets
  # have the same key set as the injected raw serviceHardenArgs.
  requiredKeys = builtins.attrNames serviceHardenArgs;

  # Services legitimately needing full/hardware access: PVE cluster daemons,
  # sshd, OVS, hardware monitors, upstream system services
  ignored = [
    # 系统核心服务
    "dbus-broker"
    "dbus"
    "enable-ksm"
    "greetd"
    "kmod-static-nodes"
    "lastlog2-import"
    "nix-daemon"
    "nix-gc"
    "nix-optimise"
    "nscd"
    "polkit"
    "reload-systemd-vconsole-setup"
    "rtkit-daemon"
    "sshd"

    # 网络管理
    "NetworkManager"
    "NetworkManager-dispatcher"
    "geoclue"
    "iwd"
    "networkd-dispatcher"

    # 硬件相关
    "acpid"
    "ananicy-cpp"
    "bluetooth"
    "fwupd"
    "fwupd-refresh"
    "irqbalance"
    "lvm2-monitor"
    "ModemManager"
    "pipewire"
    "pipewire-pulse"
    "tlp"
    "tlp-sleep"
    "wireplumber"
    "xfs_scrub_all"
    "cups"
    "cups-browsed"
    "nvidia-persistenced"
    "ovs-vswitchd"
    "ovsdb"
    "polkit"

    # Proxmox VE 相关
    "corosync"
    "pve-cluster"
    "pvedaemon"
    "pveproxy"
    "pvescheduler"
    "pvestatd"
    "qmeventd"
    "rrdcached"
    "spiceproxy"
    "usbmuxd"

    # libvirt 相关
    "libvirt-guests"
    "libvirtd"
    "virtchd"
    "virtlockd"
    "virtlogd"

    # NFS / RPC 相关
    "auth-rpcgss-module"
    "nfs-blkmap"
    "nfs-idmapd"
    "nfs-mountd"
    "nfs-server"
    "rpc-gssd"
    "rpc-statd"
    "rpcbind"

    # 其它
    "bootvine"
    "bootvine-shutdown"
    "httpd"
    "pi-web"
    "podman"
    "waagent"
    "xvcd"
  ];

  exempt =
    n: v:
    builtins.elem n ignored
    # Template definitions are hardening-independent; instances are checked by
    # name in ensure-service-restart.nix
    || lib.hasInfix "@" n
    # Disabled services
    || !(v.enable or true)
    # Oneshot and dbus-activated services
    || (builtins.elem (v.serviceConfig.Type or "") [
      "oneshot"
      "dbus"
    ])
    # Podman containers
    || lib.hasPrefix "podman-" n
    # Core system services
    || lib.hasPrefix "systemd" n;

  # builtins.hasAttr instead of the `?` operator: on Nix 2.35, `set ? var`
  # with a variable key always returns false (broken dynamic attrpath check),
  # which would flag fully hardened services as missing everything
  missingKeys = n: v: lib.filter (k: !builtins.hasAttr k v.serviceConfig) requiredKeys;

  # Mountpoints bound both writable and read-only on the same service.
  # systemd.exec(5): each entry is "source[:destination[:options]]", optionally
  # "-" prefixed to ignore missing paths; entries may be emitted quoted
  # (helpers/fn/systemd.nix escapeMountPath). The mountpoint inside the
  # namespace is the destination when present, else the source bound onto
  # itself. Both list values and single-entry strings are accepted (systemd
  # accepts both; e.g. colocrossing acme-setup binds from a string); a string
  # value is treated as one entry and never split on whitespace
  bindPathMountpoints =
    opt: v:
    let
      value = v.serviceConfig.${opt} or null;
    in
    map
      (
        entry:
        lib.last (
          lib.take 2 (
            lib.splitString ":" (lib.removePrefix "-" (builtins.replaceStrings [ "\"" ] [ "" ] entry))
          )
        )
      )
      (
        if value == null then
          [ ]
        else if builtins.isString value then
          [ value ]
        else
          value
      );

  bindPathConflicts =
    v:
    lib.intersectLists (lib.unique (bindPathMountpoints "BindPaths" v)) (
      lib.unique (bindPathMountpoints "BindReadOnlyPaths" v)
    );
in
{
  # 1. Every eligible service must set all keys from lantian.harden's preset
  # 2. Every eligible service must run inside a confinement chroot
  #    (systemd.services.<name>.confinement)
  # 3. No path may be bound in both BindPaths and BindReadOnlyPaths
  assertions =
    lib.mapAttrsToList (
      n: v:
      let
        missing = missingKeys n v;
      in
      {
        assertion = exempt n v || missing == [ ];
        message = "${n} is missing systemd service hardening options (lantian.harden): ${lib.concatStringsSep ", " missing}";
      }
    ) config.systemd.services
    ++ lib.mapAttrsToList (
      n: v:
      let
        # Services already chrooted outside of the confinement module count too:
        # upstream endlessh sets RootDirectory itself. An explicitly declared
        # lantian.harden.<name>.enableConfinement = false is also a valid
        # per-service opt-out, if harden itself is enabled.
        confined =
          (v.confinement.enable or false)
          || (v.serviceConfig.RootDirectory or null) != null
          || (config.lantian.harden.${n}.enable or false) != false;
      in
      {
        assertion = exempt n v || confined;
        message = "${n} must enable systemd.services.<name>.confinement (RootDirectory+BindPaths whitelist); bind any needed state/socket paths inside the chroot";
      }
    ) config.systemd.services
    ++ lib.mapAttrsToList (
      n: v:
      let
        conflicts = bindPathConflicts v;

        # systemd src/core/namespace.c drop_duplicates(): duplicate mountpoints
        # are deduplicated and the more restrictive read-only bind wins, so the
        # other binding is silently discarded
      in
      {
        assertion = !(v.enable or true) || conflicts == [ ];
        message = "${n} binds the same paths in both BindPaths and BindReadOnlyPaths (systemd discards the duplicate; the read-only bind wins): ${lib.concatStringsSep ", " conflicts}";
      }
    ) config.systemd.services;
}
