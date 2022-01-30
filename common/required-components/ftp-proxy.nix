{ pkgs, config, options, ... }:

let
  LT = import ../helpers.nix { inherit config pkgs; };
in
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
    serviceConfig = LT.serviceHarden // {
      Type = "forking";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.ftp-proxy}/bin/ftp.proxy -D 21 -m ${config.services."ftp-proxy".target}";

      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      DynamicUser = true;
    };
  };
}
