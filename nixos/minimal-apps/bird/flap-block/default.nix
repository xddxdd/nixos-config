{
  pkgs,
  lib,
  LT,
  ...
}:
let
  py = pkgs.python3.withPackages (ps: with ps; [ requests ]);
  filePath = "/var/cache/bird/flap-block.conf";
in
lib.mkIf (LT.this.hasTag LT.tags.dn42) {
  systemd.services.flap-block = {
    description = "Gather flapping routes and block them";
    script = ''
      ${py}/bin/python3 ${./gather_flapalerted.py} ${filePath}
      ${pkgs.systemd}/bin/systemctl reload bird.service
    '';
    serviceConfig = {
      Type = "oneshot";
      Restart = "no";
    };
  };

  systemd.timers.flap-block = {
    wantedBy = [ "timers.target" ];
    partOf = [ "flap-block.service" ];
    timerConfig = {
      OnCalendar = "*:0/5";
      Persistent = true;
      Unit = "flap-block.service";
      RandomizedDelaySec = "5min";
    };
  };

  systemd.tmpfiles.settings = {
    bird-flap-block = {
      "${filePath}"."f" = {
        mode = "644";
        user = "root";
        group = "root";
      };
    };
  };
}
