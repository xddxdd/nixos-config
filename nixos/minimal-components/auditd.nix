{
  config,
  lib,
  LT,
  ...
}:
let
  hardenArgs = (import ../../helpers/fn/service-harden.nix { inherit lib; }).serviceHardenArgs;
  auditFiles = lib.filterAttrs (name: _: lib.hasPrefix "audit/" name) config.environment.etc;
  auditedSecrets = lib.filterAttrs (_: secret: secret.audit) config.lantian.secrets;
  serviceRule =
    path: key: field:
    "-a always,exit -S all -F dir=${path} -F ${field}>=1 -F ${field}<=999 -k ${key}";
  homeRules =
    lib.concatMap
      (
        path:
        map (serviceRule path "service-home") [
          "uid"
          "euid"
          "fsuid"
        ]
      )
      [
        "/home"
        "/root"
      ];
  secretRules = map (secret: "-a always,exit -S all -F path=${secret.path} -k credential-access") (
    lib.attrValues auditedSecrets
  );
in
{
  assertions = [
    {
      # auditctl -R splits fields on whitespace; it does not shell-unquote paths.
      assertion = lib.all (secret: builtins.match ".*[[:space:]].*" secret.path == null) (
        lib.attrValues auditedSecrets
      );
      message = "Audited lantian.secrets paths cannot contain whitespace in the native auditctl rule file.";
    }
  ];
  security.auditd.enable = true;
  security.audit = {
    enable = true;
    backlogLimit = lib.mkDefault 8192;
    # First match wins: file-specific rules precede broader directory watches.
    rules = lib.mkBefore (
      secretRules
      ++ homeRules
      ++ map (serviceRule "/nix/persistent" "persistent-access") [
        "uid"
        "euid"
        "fsuid"
      ]
      ++ [
        # An inaccessible ancestor prevents inode/path rules from matching. Log
        # denials globally so these attempted accesses are not silently missed.
        "-a always,exit -S all -F exit=-EACCES -k access-denied"
        "-a always,exit -S all -F exit=-EPERM -k access-denied"
      ]
    );
  };

  security.auditd.settings = {
    log_file = "/var/log/audit/audit.log";
    max_log_file_action = "rotate";
    num_logs = 5;
    max_log_file = 25;
  };
  # journald lives under /nix/persistent too. Forwarding every record into it
  # recursively audits the forwarding writes; keep the native auditd trail.
  security.auditd.plugins.syslog.active = false;
  # The journal's audit-netlink socket is a separate route around that plugin.
  # Its records otherwise make the regular journal shipper audit its own I/O.
  systemd.sockets.systemd-journald-audit.enable = false;

  systemd.services.audit-rules-nixos = {
    partOf = [
      "auditd.service"
    ]
    ++ lib.optional (config.lantian.secrets != { }) "lantian-secrets.service";
    after = [
      "local-fs.target"
      "systemd-tmpfiles-setup.service"
      "auditd.service"
    ]
    ++ lib.optional (config.lantian.secrets != { }) "lantian-secrets.service";
    requires = [
      "auditd.service"
    ]
    ++ lib.optional (config.lantian.secrets != { }) "lantian-secrets.service";
    unitConfig.RequiresMountsFor = [
      "/home"
      "/root"
      "/nix/persistent"
    ];
    # Load after existing filesystems and credentials; the kernel tags subtrees
    # already mounted when the native NixOS auditctl -R loader installs watches.
    serviceConfig = {
      TimeoutStartSec = "2min";
      NoNewPrivileges = true;
      CapabilityBoundingSet = [
        "CAP_AUDIT_CONTROL"
        "CAP_DAC_READ_SEARCH"
      ];
    };
  };

  systemd.services.auditd = {
    # Config files are bound into its private root; reload alone leaves those
    # mounts pointing at the previous configuration's store paths.
    restartTriggers = lib.mapAttrsToList (_: value: value.source) auditFiles;
    # A switch must recreate the confinement when config store paths change.
    unitConfig.RefuseManualStop = false;
    serviceConfig = LT.serviceHarden // {
      Restart = "on-failure";
      RestartSec = "5s";
      AmbientCapabilities = [
        "CAP_AUDIT_CONTROL"
        "CAP_AUDIT_READ"
        "CAP_SYS_NICE"
      ];
      CapabilityBoundingSet = [
        "CAP_AUDIT_CONTROL"
        "CAP_AUDIT_READ"
        "CAP_SYS_NICE"
      ];
      PrivateUsers = false;
      RestrictAddressFamilies = [
        "AF_NETLINK"
        "AF_UNIX"
      ];
      ProcSubset = "all";
      ProtectProc = "default";
      OOMScoreAdjust = -1000;
      # auditd changes log ownership and scheduling priority as it rotates.
      SystemCallFilter = hardenArgs.SystemCallFilter ++ [
        "@chown"
        "@resources"
      ];
      BindPaths = [
        "/var/log/audit"
        "/run/audit"
      ];
      BindReadOnlyPaths = lib.mapAttrsToList (name: value: "${value.source}:/etc/${name}") auditFiles;
    };
    # This early kernel/syslog daemon needs no DNS or CA bindings. In particular,
    # /etc/resolv.conf may not exist before the network manager starts.
    confinement = {
      enable = true;
      fullUnit = true;
    };
  };
}
