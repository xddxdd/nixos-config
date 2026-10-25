{
  pkgs,
  lib,
  config,
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

  config.lantian.harden.ftp-proxy = {
    enable = true;
    enableConfinement = false;
  };
  config.systemd.services.ftp-proxy = {
    inherit (config.services."ftp-proxy") enable;
    description = "FTP Proxy";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      After = "network.target";
    };
    serviceConfig = {
      Type = "forking";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${lib.getExe pkgs.nur-xddxdd.ftp-proxy} -D 21 -m ${
        config.services."ftp-proxy".target
      }";

      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      DynamicUser = true;
    };
  };
}
