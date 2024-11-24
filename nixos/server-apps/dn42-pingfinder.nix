{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.services."dn42-pingfinder" = {
    uuidFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "UUID of the pingfinder service";
    };
  };

  config = lib.mkIf (config.services."dn42-pingfinder".uuidFile != null) {
    systemd.services.dn42-pingfinder = {
      path = with pkgs; [
        curl
        inetutils
        which
        util-linux
      ];
      script = ''
        export UUID=$(cat ${config.services."dn42-pingfinder".uuidFile})
        exec ${pkgs.nur-xddxdd.dn42-pingfinder}/bin/dn42-pingfinder
      '';
      serviceConfig = {
        Type = "oneshot";
        TimeoutSec = 900;
        RuntimeDirectory = "dn42-pingfinder";
        WorkingDirectory = "/run/dn42-pingfinder";
        CPUQuota = "10%";
      };
      unitConfig = {
        After = "network.target";
      };
    };

    systemd.timers.dn42-pingfinder = {
      wantedBy = [ "timers.target" ];
      partOf = [ "dn42-pingfinder.service" ];
      timerConfig = {
        OnCalendar = "*:0/5";
        Persistent = true;
        Unit = "dn42-pingfinder.service";
      };
    };
  };
}
