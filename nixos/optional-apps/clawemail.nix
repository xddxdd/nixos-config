{
  LT,
  config,
  ...
}:
{
  sops.templates.clawemail-env.content = ''
    ADMIN_PASSWORD=${config.sops.placeholder.default-pw}
  '';

  virtualisation.oci-containers.containers.clawemail = {
    image = "ghcr.io/wangxingfan/clawemail:latest";
    labels."io.containers.autoupdate" = "registry";
    ports = [ "127.0.0.1:${LT.portStr.ClawEmail}:${LT.portStr.ClawEmail}" ];
    volumes = [ "/var/lib/clawemail:/app/data" ];
    environmentFiles = [ config.sops.templates.clawemail-env.path ];
    environment = {
      NODE_ENV = "production";
      PORT = LT.portStr.ClawEmail;
      DATABASE_PATH = "/app/data/app.db";
    };
  };

  systemd.tmpfiles.settings = {
    clawemail = {
      "/var/lib/clawemail"."d" = {
        mode = "755";
        user = "root";
        group = "root";
      };
    };
  };

  lantian.nginxVhosts = {
    "clawemail.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.ClawEmail}";
        };
      };

      accessibleBy = "private";
      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
    "clawemail.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.ClawEmail}";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
