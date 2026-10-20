{
  pkgs,
  lib,
  config,
  ...
}:
let
  rtpengineConfig = pkgs.writeText "rtpengine.conf" (
    builtins.replaceStrings [ "address = any" ] [ "address = 192.168.0.9" ] (
      builtins.readFile ./rtpengine.conf
    )
  );
in
{
  boot.kernelModules = [ "xt_RTPENGINE" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.xt_rtpengine ];

  systemd.services.rtpengine = {
    description = "NGCP RTP/media Proxy Daemon";
    requires = [ "network.target" ];
    after = [
      "network.target"
      "systemd-modules-load.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      RuntimeDirectory = "rtpengine";
      CacheDirectory = "rtpengine";
      PIDFile = "/run/rtpengine/ngcp-rtpengine-daemon.pid";
      User = "rtpengine";
      Group = "rtpengine";
      LimitNOFILE = 150000;
      LimitMEMLOCK = 8388608;
      UMask = "0077";

      Restart = "always";
      RestartSec = "5";

      ExecStart = builtins.concatStringsSep " " [
        (lib.getExe pkgs.nur-xddxdd.rtpengine)
        "-f"
        "-E"
        "--no-log-timestamps"
        "--pidfile /run/rtpengine/ngcp-rtpengine-daemon.pid"
        "--config-file ${rtpengineConfig}"
      ];

      # https://github.com/sipwise/rtpengine/blob/master/debian/ngcp-rtpengine-daemon.service
      MemoryDenyWriteExecute = true;
      # Kernel forwarding controls and load monitoring live outside /proc/<pid>.
      ProcSubset = "all";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      ReadWritePaths = [
        "/var/cache/rtpengine"
        "-/proc/rtpengine"
      ];
      ProtectKernelLogs = true;
      ProtectProc = "invisible";
      SystemCallArchitectures = "native";
      # The module's procfs controls default to root:root ownership.
      CapabilityBoundingSet = [
        "CAP_DAC_OVERRIDE"
        "CAP_NET_ADMIN"
        "CAP_SYS_NICE"
      ];
      AmbientCapabilities = [
        "CAP_DAC_OVERRIDE"
        "CAP_NET_ADMIN"
        "CAP_SYS_NICE"
      ];
      PrivateTmp = true;
      PrivateDevices = true;
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateUsers = false;
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_NETLINK"
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      PrivateNetwork = false;
      DevicePolicy = "closed";
      IPAddressDeny = "any";
      IPAddressAllow = [
        "localhost"
        "192.168.0.0/24"
        "192.168.4.0/24"
        "2001:470:e997:4000::/52"
      ];
      SystemCallFilter = "@system-service";
      SystemCallErrorNumber = "ENOSYS";
      SystemCallLog = "~@system-service seccomp";

      PrivateMounts = true;
      # Keep upstream's userspace fallback usable before the matching kernel boots.
      BindPaths = [
        "/var/cache/rtpengine"
        "-/proc/rtpengine"
      ];
    };

    confinement = {
      enable = true;
      fullUnit = true;
    };
  };

  lantian.harden.rtpengine = true;

  users.users.rtpengine = {
    group = "rtpengine";
    isSystemUser = true;
  };
  users.groups.rtpengine = { };
}
