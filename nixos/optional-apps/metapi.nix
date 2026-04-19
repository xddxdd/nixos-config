{
  LT,
  config,
  inputs,
  ...
}:
{
  sops.secrets.metapi-env.sopsFile = inputs.secrets + "/metapi.yaml";

  virtualisation.oci-containers.containers.metapi = {
    image = "ghcr.io/cita-777/metapi:latest";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    ports = [ "127.0.0.1:${LT.portStr.Metapi}:4000" ];
    volumes = [
      "/var/lib/metapi:/app/data"
    ];
    environment = {
      CHECKIN_CRON = "0 8 * * *";
      BALANCE_REFRESH_CRON = "0 * * * *";
      PORT = "4000";
      DATA_DIR = "/app/data";
      TZ = config.time.timeZone;
    };
    environmentFiles = [ config.sops.secrets.metapi-env.path ];
  };

  systemd.tmpfiles.settings = {
    metapi = {
      "/var/lib/metapi"."d" = {
        mode = "755";
        user = "root";
        group = "root";
      };
    };
  };

  lantian.nginxVhosts."metapi.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Metapi}";
        proxyWebsockets = true;
      };
    };

    accessibleBy = "private";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
