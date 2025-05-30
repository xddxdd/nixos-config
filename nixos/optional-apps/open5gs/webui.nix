{
  pkgs,
  LT,
  config,
  ...
}:
{
  systemd.services.open5gs-webui = {
    description = "Open5GS WebUI";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "mongodb.service"
    ];
    requires = [
      "network.target"
      "mongodb.service"
    ];
    path = with pkgs; [
      bash
      nodejs
      rsync
      nodejs
    ];
    environment = {
      HOSTNAME = "127.0.0.1";
      PORT = LT.portStr.Open5GS;
    };
    preStart = ''
      export HOME=$(pwd)
      rsync -r --chmod=D755,F755 ${pkgs.open5gs.src}/webui/ .
      npm install
      npm run build
    '';
    serviceConfig = {
      ExecStart = "${pkgs.nodejs}/bin/npm run start";
      CacheDirectory = "open5gs";
      WorkingDirectory = "/var/cache/open5gs";
      User = "open5gs";
      Group = "open5gs";
      Restart = "always";
      RestartSec = "5";
    };
  };

  lantian.nginxVhosts = {
    "open5gs.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Open5GS}";
        };
      };

      sslCertificate = "lets-encrypt-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
      accessibleBy = "private";
    };
  };
}
