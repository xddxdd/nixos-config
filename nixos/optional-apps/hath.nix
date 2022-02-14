{ pkgs, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };

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
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.hath}/bin/hath --cache-dir=${hathCacheDir} --data-dir=${hathDataDir} --download-dir=${hathDownloadDir} --log-dir=${hathLogDir} --temp-dir=${hathTempDir}";

      MemoryDenyWriteExecute = false;
      RuntimeDirectory = "hath";
      StateDirectory = "hath";
      CacheDirectory = "hath";
      LogsDirectory = "hath";
      User = "hath";
      Group = "hath";
    };
  };

  users.users.hath = {
    group = "hath";
    isSystemUser = true;
  };
  users.groups.hath = { };
}
