{
  LT,
  config,
  pkgs,
  lib,
  ...
}:
let
  models = pkgs.fetchgit {
    inherit (LT.sources.firefox-translations-models.src) url rev;
    fetchLFS = true;
    sha256 = "sha256-pck2oniMw+Pt6miMT0k1A1ZUMFKBAUpqA4dy3b8JSHk=";
  };

  enabledModels = pkgs.runCommand "mtranserver-models" { } ''
    mkdir -p $out
    cp -r ${models}/models/base-memory/* $out/
    chmod -R +w $out
    ${lib.getExe' pkgs.gzip "gunzip"} -r $out
  '';
in
{
  systemd.services.mtranserver = {
    description = "MTranServer";
    wantedBy = [ "multi-user.target" ];

    environment = {
      IP = "127.0.0.1";
      PORT = LT.portStr.MTranServer;
      MODELS_DIR = builtins.toString enabledModels;
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

  lantian.nginxVhosts."mtranserver.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.MTranServer}";
        proxyNoTimeout = true;
      };
    };

    accessibleBy = "private";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
