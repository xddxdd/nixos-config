{
  pkgs,
  config,
  utils,
  ...
}:
let
  loggingConf = {
    Serilog = {
      Using = [ "Serilog.Sinks.Console" ];
      MinimumLevel = "Warning";
      WriteTo = [ { Name = "Console"; } ];
      Enrich = [
        "FromLogContext"
        "WithMachineName"
        "WithThreadId"
      ];
      Properties.Application = "Jellyfin";
    };
  };

  netns = config.lantian.netns.jellyfin;
in
{
  services.jellyfin.enable = true;

  lantian.netns.jellyfin.ipSuffix = "48";

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

      sslCertificate = "zerossl-xuyh0120.win";
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

  systemd.services.jellyfin = netns.bind {
    environment = {
      JELLYFIN_kestrel__socket = "true";
      JELLYFIN_kestrel__socketPath = "/run/jellyfin/socket";
      JELLYFIN_kestrel__socketPermissions = "0777";
      JELLYFIN_PublishedServerUrl = "https://jellyfin.xuyh0120.win";
    };
    serviceConfig = {
      RuntimeDirectory = "jellyfin";
      ExecStartPre = pkgs.writeShellScript "jellyfin-pre" ''
        ${utils.genJqSecretsReplacementSnippet loggingConf "/var/lib/jellyfin/config/logging.json"}
      '';
    };
  };

  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];
}
