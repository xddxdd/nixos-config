{
  pkgs,
  lib,
  LT,
  config,
  options,
  utils,
  inputs,
  ...
} @ args: {
  options.lantian.hath = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    cacheDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/cache/hath";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/hath";
    };
    downloadDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/hath";
    };
    logDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/log/hath";
    };
    tempDir = lib.mkOption {
      type = lib.types.str;
      default = "/run/hath";
    };
  };

  config = lib.mkIf config.lantian.hath.enable {
    systemd.services.hath = {
      description = "Hentai@Home";
      after = ["network.target"];
      wants = ["network.target"];
      wantedBy = ["multi-user.target"];
      script = ''
        exec ${pkgs.jre_headless}/bin/java \
          -Xms16m -Xmx128m \
          -jar ${pkgs.hath}/opt/HentaiAtHome.jar \
          --cache-dir=${config.lantian.hath.cacheDir} \
          --data-dir=${config.lantian.hath.dataDir} \
          --download-dir=${config.lantian.hath.downloadDir} \
          --log-dir=${config.lantian.hath.logDir} \
          --temp-dir=${config.lantian.hath.tempDir} \
          --use-less-memory
      '';
      serviceConfig =
        LT.serviceHarden
        // {
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

          ReadWritePaths = [
            config.lantian.hath.cacheDir
            config.lantian.hath.dataDir
            config.lantian.hath.downloadDir
            config.lantian.hath.logDir
            config.lantian.hath.tempDir
          ];
        };
    };

    systemd.tmpfiles.rules = [
      "d ${config.lantian.hath.cacheDir} 755 hath hath"
      "d ${config.lantian.hath.dataDir} 755 hath hath"
      "d ${config.lantian.hath.downloadDir} 755 hath hath"
      "d ${config.lantian.hath.logDir} 755 hath hath"
      "d ${config.lantian.hath.tempDir} 755 hath hath"
    ];

    users.users.hath = {
      group = "hath";
      isSystemUser = true;
    };
    users.groups.hath = {};
  };
}
