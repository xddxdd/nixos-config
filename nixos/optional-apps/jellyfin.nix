{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  loggingConf = {
    Serilog = {
      Using = ["Serilog.Sinks.Console"];
      MinimumLevel = "Warning";
      WriteTo = [{Name = "Console";}];
      Enrich = ["FromLogContext" "WithMachineName" "WithThreadId"];
      Properties.Application = "Jellyfin";
    };
  };
in {
  services.jellyfin.enable = true;

  services.nginx.virtualHosts = {
    "jellyfin.${config.networking.hostName}.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://unix:/run/jellyfin/socket";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig =
        LT.nginx.makeSSL "${config.networking.hostName}.xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
    "jellyfin.localhost" = {
      listen = LT.nginx.listenHTTP;
      locations = LT.nginx.addCommonLocationConf {} {
        "/" = {
          proxyPass = "http://unix:/run/jellyfin/socket";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig =
        LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true
        + LT.nginx.serveLocalhost;
    };
  };

  systemd.services.douban-openapi-server = {
    description = "Douban OpenAPI Server";
    wantedBy = ["multi-user.target"];
    script = ''
      exec ${pkgs.douban-openapi-server}/bin/douban-openapi-server \
        --access-logfile - \
        -b 127.0.0.1:5000 \
        -w 3
    '';
    serviceConfig =
      LT.serviceHarden
      // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        TimeoutStopSec = "5";
      };
  };

  systemd.services.jellyfin = {
    environment = {
      JELLYFIN_kestrel__socket = "true";
      JELLYFIN_kestrel__socketPath = "/run/jellyfin/socket";
    };
    serviceConfig = {
      RuntimeDirectory = "jellyfin";
      ExecStartPre = pkgs.writeShellScript "jellyfin-pre" ''
        ${utils.genJqSecretsReplacementSnippet loggingConf "/var/lib/jellyfin/config/logging.json"}
      '';
      ExecStartPost = pkgs.writeShellScript "jellyfin-post" ''
        while [ ! -S /run/jellyfin/socket ]; do sleep 1; done
        chmod 777 /run/jellyfin/socket
      '';
    };
  };

  users.users.jellyfin.extraGroups = ["video" "render"];
}
