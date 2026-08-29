{
  pkgs,
  lib,
  LT,
  ...
}:
{
  imports = [ ../mongodb.nix ];

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
      ExecStart = "${lib.getExe' pkgs.nodejs "npm"} run start";
      CacheDirectory = "open5gs";
      WorkingDirectory = "/var/cache/open5gs";
      User = "open5gs";
      Group = "open5gs";
      Restart = "always";
      RestartSec = "5";
    };
  };

  lantian.localVhosts.open5gs = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Open5GS}";
      };
    };
  };
}
