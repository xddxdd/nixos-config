{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  py = pkgs.python3.withPackages (p: with p; [
    httpx
    python-crontab
    pyyaml
    requests
  ]);

  files = pkgs.callPackage ./files.nix { inherit (LT) sources; };
in
{
  systemd.services.auto-mihoyo-bbs = {
    environment = {
      AutoMihoyoBBS_config_path = "/var/lib/auto-mihoyo-bbs";
    };
    path = with pkgs; [ git ];
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      TimeoutSec = 3600;
      Restart = "on-failure";
      RestartSec = 30;
      StateDirectory = "auto-mihoyo-bbs";
      WorkingDirectory = "/var/lib/auto-mihoyo-bbs";
    };
    unitConfig = {
      OnSuccess = "notify-email@%n.service";
      OnFailure = "notify-email@%n.service";
    };
    after = [ "network.target" ];
    script = ''
      export AutoMihoyoBBS_appkey=$(cat /var/lib/auto-mihoyo-bbs/appkey)
      exec ${py}/bin/python ${files}/main.py
    '';
  };

  systemd.timers.auto-mihoyo-bbs = {
    wantedBy = [ "timers.target" ];
    partOf = [ "auto-mihoyo-bbs.service" ];
    timerConfig = {
      OnCalendar = "*-*-* 14:30:00";
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "auto-mihoyo-bbs.service";
    };
  };
}