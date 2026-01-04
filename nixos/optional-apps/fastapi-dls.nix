{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  systemd.services.fastapi-dls = {
    description = "FastAPI-DLS";
    wantedBy = [ "multi-user.target" ];
    environment = {
      DLS_URL = "fastapi-dls.${config.networking.hostName}.xuyh0120.win";
      DLS_PORT = "443";
      LEASE_RENEWAL_PERIOD = "0.01";
      DATABASE = "sqlite:///var/lib/fastapi-dls/db.sqlite";
      INSTANCE_KEY_RSA = "/var/lib/fastapi-dls/instance.private.pem";
      INSTANCE_KEY_PUB = "/var/lib/fastapi-dls/instance.public.pem";
    };

    path = with pkgs; [ openssl ];

    preStart = ''
      if [ ! -f "/var/lib/fastapi-dls/instance.private.pem" ]; then
        openssl genrsa -out /var/lib/fastapi-dls/instance.private.pem 2048
        openssl rsa -in /var/lib/fastapi-dls/instance.private.pem \
                    -outform PEM -pubout \
                    -out /var/lib/fastapi-dls/instance.public.pem
      fi
    '';

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${lib.getExe pkgs.nur-xddxdd.fastapi-dls} --uds /run/fastapi-dls/fastapi-dls.sock --proxy-headers";
      RuntimeDirectory = "fastapi-dls";
      StateDirectory = "fastapi-dls";
      User = "fastapi-dls";
      Group = "fastapi-dls";
    };
  };

  lantian.nginxVhosts."fastapi-dls.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/fastapi-dls/fastapi-dls.sock";
      };
    };
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    accessibleBy = "private";
    noIndex.enable = true;
  };

  users.users.fastapi-dls = {
    group = "fastapi-dls";
    isSystemUser = true;
  };
  users.groups.fastapi-dls = { };
}
