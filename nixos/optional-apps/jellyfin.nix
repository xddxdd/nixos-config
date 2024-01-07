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

  lantian.nginxVhosts = {
    "jellyfin.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://unix:/run/jellyfin/socket";
        };
        "= /web/" = {
          proxyPass = "http://unix:/run/jellyfin/socket:/web/index.html";
        };
      };

      sslCertificate = "xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "jellyfin.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://unix:/run/jellyfin/socket";
        };
        "= /web/" = {
          proxyPass = "http://unix:/run/jellyfin/socket:/web/index.html";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
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
