{ pkgs, config, options, ... }:

{
  options.services."ftp-proxy" = {
    enable = pkgs.lib.mkOption {
      type = pkgs.lib.types.bool;
      default = false;
      description = "Enable ftp-proxy service.";
    };
    target = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
      default = "";
      description = "Proxied FTP server.";
    };
  };

  config.systemd.services.ftp-proxy = {
    enable = config.services."ftp-proxy".enable;
    description = "FTP Proxy";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      After = "network.target";
    };
    serviceConfig = {
      Type = "forking";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur.repos.xddxdd.ftp-proxy}/bin/ftp.proxy -D 21 -m ${config.services."ftp-proxy".target}";
      User = "nobody";

      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      NoNewPrivileges = true;

      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      PrivateMounts = true;
    };
  };
}
