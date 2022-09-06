{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  services.jellyfin.enable = true;

  services.nginx.virtualHosts = {
    "jellyfin.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { } {
        "/".extraConfig = ''
          proxy_pass http://unix:/run/jellyfin/socket;
        '' + LT.nginx.locationProxyConf;
      };
      extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
    "jellyfin.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf { } {
        "/".extraConfig = ''
          proxy_pass http://unix:/run/jellyfin/socket;
        '' + LT.nginx.locationProxyConf;
      };
      extraConfig = LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost;
    };
  };

  systemd.services.jellyfin = {
    environment = {
      JELLYFIN_kestrel__socket = "true";
      JELLYFIN_kestrel__socketPath = "/run/jellyfin/socket";
    };
    serviceConfig = {
      RuntimeDirectory = "jellyfin";
      ExecStartPost = pkgs.writeShellScript "jellyfin-post" ''
        while [ ! -S /run/jellyfin/socket ]; do sleep 1; done
        chmod 777 /run/jellyfin/socket
      '';
    };
  };

  users.users.jellyfin.extraGroups = [ "video" "render" ];

  virtualisation.oci-containers.containers = {
    douban-openapi-server = {
      extraOptions = [ "--pull" "always" ];
      image = "caryyu/douban-openapi-server:latest";
      ports = [
        "127.0.0.1:5000:5000"
      ];
    };
  };
}
