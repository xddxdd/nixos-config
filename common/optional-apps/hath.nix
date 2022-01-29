{ pkgs, config, ... }:

let
  hathCacheDir = "/var/cache/hath";
  hathDataDir = "/var/lib/hath";
  hathDownloadDir = "/var/lib/hath";
  hathLogDir = "/var/log/hath";
  hathTempDir = "/tmp/hath";
in
{
  systemd.services.hath = {
    description = "Hentai@Home";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.hath}/bin/hath --cache-dir=${hathCacheDir} --data-dir=${hathDataDir} --download-dir=${hathDownloadDir} --log-dir=${hathLogDir} --temp-dir=${hathTempDir}";
    };
  };

  systemd.tmpfiles.rules = [
    "d /tmp/hath 755 root root"
  ];
}
