{
  LT,
  pkgs,
  lib,
  ...
}:
let
  modelsData = builtins.fromJSON (builtins.readFile ./models.json);
  modelsDir = pkgs.linkFarm "mtranserver-models" (
    lib.mapAttrs (
      _: f:
      pkgs.fetchurl {
        inherit (f) url;
        hash = "sha256:${f.sha256}";
      }
    ) modelsData
  );
in
{
  systemd.services.mtranserver = {
    description = "MTranServer";
    wantedBy = [ "multi-user.target" ];

    environment = {
      IP = "127.0.0.1";
      PORT = LT.portStr.MTranServer;
      MODELS_DIR = builtins.toString modelsDir;
      NUM_WORKERS = "4";
    };

    serviceConfig = LT.serviceHarden // {
      ExecStart = lib.getExe pkgs.nur-xddxdd.linguaspark-server-x86-64-v3;
      User = "mtranserver";
      Group = "mtranserver";

      Restart = "always";
      RestartSec = "5";
    };
  };

  users.users.mtranserver = {
    group = "mtranserver";
    isSystemUser = true;
  };
  users.groups.mtranserver = { };

  lantian.localVhosts.mtranserver = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.MTranServer}";
        proxyNoTimeout = true;
      };
    };
  };
}
