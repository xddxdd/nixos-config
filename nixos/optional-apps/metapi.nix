{
  LT,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets.metapi-admin-key = {
    sopsFile = inputs.secrets + "/uni-api/keys.yaml";
    key = "uni-api-admin-api-key";
    owner = "metapi";
    group = "metapi";
  };

  systemd.services.metapi = {
    description = "Metapi";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      CHECKIN_CRON = "0 8 * * *";
      BALANCE_REFRESH_CRON = "0 * * * *";
      HOST = "127.0.0.1";
      PORT = LT.portStr.Metapi;
      DATA_DIR = "/var/lib/metapi";
      TZ = config.time.timeZone;
    };

    script = ''
      export AUTH_TOKEN=$(cat ${config.sops.secrets.default-pw.path})
      export PROXY_TOKEN=$(cat ${config.sops.secrets.metapi-admin-key.path})
      exec ${lib.getExe pkgs.nur-xddxdd.metapi}
    '';

    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = "5";
      User = "metapi";
      Group = "metapi";
      MemoryDenyWriteExecute = lib.mkForce false;
      StateDirectory = "metapi";
      WorkingDirectory = "/var/lib/metapi";
    };
  };

  users.users.metapi = {
    group = "metapi";
    isSystemUser = true;
  };
  users.groups.metapi = { };

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
