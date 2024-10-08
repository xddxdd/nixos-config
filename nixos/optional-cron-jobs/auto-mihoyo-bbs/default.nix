{ pkgs, LT, ... }:
let
  py = pkgs.python3.withPackages (
    p: with p; [
      httpx
      python-crontab
      pyyaml
      requests
    ]
  );

  files = pkgs.callPackage ./files.nix { inherit (LT) sources; };
in
{
  systemd.services.auto-mihoyo-bbs = {
    environment = {
      AutoMihoyoBBS_config_path = "/var/lib/auto-mihoyo-bbs";
    };
    path = with pkgs; [ gitMinimal ];
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      TimeoutSec = 3600;
      StateDirectory = "auto-mihoyo-bbs";
      WorkingDirectory = "/var/lib/auto-mihoyo-bbs";
      Restart = "on-failure";
      RestartSec = "1800";
    };
    unitConfig = {
      OnFailure = "notify-email-fail@%n.service";
    };
    after = [ "network.target" ];
    script = ''
      set -euo pipefail
      export AutoMihoyoBBS_appkey=$(cat /var/lib/auto-mihoyo-bbs/appkey)
      grep -E "^enable: true" config.yaml
      sed -i "s/auto_checkin: false/auto_checkin: true/g" config.yaml || true
      exec ${py}/bin/python ${files}/main.py
    '';
  };

  systemd.timers.auto-mihoyo-bbs = {
    wantedBy = [ "timers.target" ];
    partOf = [ "auto-mihoyo-bbs.service" ];
    timerConfig = {
      OnCalendar = [
        "*-*-* 02:30:00"
        "*-*-* 14:30:00"
      ];
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "auto-mihoyo-bbs.service";
    };
  };
}
