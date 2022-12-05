{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;

  hathCacheDir = "/var/cache/hath";
  hathDataDir = "/var/lib/hath";
  hathDownloadDir = "/var/lib/hath";
  hathLogDir = "/var/log/hath";
  hathTempDir = "/run/hath";
in
{
  systemd.services.hath = {
    description = "Hentai@Home";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      exec ${pkgs.jre_headless}/bin/java \
        -Xms16m -Xmx128m \
        -jar ${pkgs.hath}/opt/HentaiAtHome.jar \
        --cache-dir=${hathCacheDir} \
        --data-dir=${hathDataDir} \
        --download-dir=${hathDownloadDir} \
        --log-dir=${hathLogDir} \
        --temp-dir=${hathTempDir} \
        --use-less-memory
    '';
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      MemoryDenyWriteExecute = false;
      RuntimeDirectory = "hath";
      StateDirectory = "hath";
      CacheDirectory = "hath";
      LogsDirectory = "hath";
      User = "hath";
      Group = "hath";

      # Disable logging
      StandardOutput = "null";
      StandardError = "null";
    };
  };

  users.users.hath = {
    group = "hath";
    isSystemUser = true;
  };
  users.groups.hath = { };
}
