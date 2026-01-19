{
  pkgs,
  lib,
  config,
  ...
}:
{
  boot.kernelModules = [ "xt_RTPENGINE" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.xt_rtpengine ];

  systemd.services.rtpengine = {
    description = "NGCP RTP/media Proxy Daemon";
    requires = [ "network.target" ];
    after = [ "network.target" ];
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
        "--interface=192.168.0.9"
        "--no-log-timestamps"
        "--pidfile /run/rtpengine/ngcp-rtpengine-daemon.pid"
        "--config-file ${./rtpengine.conf}"
      ];

      # https://github.com/sipwise/rtpengine/blob/master/debian/ngcp-rtpengine-daemon.service
      MemoryDenyWriteExecute = true;
      ProcSubset = "all";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/cache/rtpengine" ];
      ProtectKernelLogs = true;
      ProtectProc = "invisible";
      SystemCallArchitectures = "native";
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_SYS_NICE"
      ];
      AmbientCapabilities = [
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
      IPAddressAllow = "any";
      SystemCallFilter = "@system-service";
      SystemCallErrorNumber = "ENOSYS";
      SystemCallLog = "~@system-service seccomp";
    };
  };

  users.users.rtpengine = {
    group = "rtpengine";
    isSystemUser = true;
  };
  users.groups.rtpengine = { };
}
