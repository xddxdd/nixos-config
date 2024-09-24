{
  pkgs,
  lib,
  LT,
  config,
  options,
  ...
}:
{
  options.services."ftp-proxy" = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable ftp-proxy service.";
    };
    target = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Proxied FTP server.";
    };
  };

  config.systemd.services.ftp-proxy = {
    inherit (config.services."ftp-proxy") enable;
    description = "FTP Proxy";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      After = "network.target";
    };
    serviceConfig = LT.serviceHarden // {
      Type = "forking";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur-xddxdd.ftp-proxy}/bin/ftp.proxy -D 21 -m ${
        config.services."ftp-proxy".target
      }";

      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      DynamicUser = true;
    };
  };
}
