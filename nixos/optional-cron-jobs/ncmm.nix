{
  lib,
  pkgs,
  LT,
  ...
}:
let
  ncmmWrapped =
    pkgs.runCommand "ncmm-wrapped"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      }
      ''
        mkdir -p $out/bin
        makeWrapper ${lib.getExe pkgs.nur-xddxdd.ncmm} $out/bin/ncmm \
          --add-flags "--home /var/lib/ncmm"
      '';
in
{
  environment.systemPackages = [ ncmmWrapped ];

  systemd.services.ncmm = {
    unitConfig = {
      OnFailure = "notify-email@%n.service";
    };
    serviceConfig = LT.serviceHarden // {
      ExecStart = "${ncmmWrapped}/bin/ncmm musician-vip";
      Type = "oneshot";
      StateDirectory = "ncmm";
      WorkingDirectory = "/var/lib/ncmm";
      User = "ncmm";
      Group = "ncmm";
    };
  };

  systemd.timers.ncmm = {
    wantedBy = [ "timers.target" ];
    partOf = [ "ncmm.service" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "12h";
      Unit = "ncmm.service";
    };
  };

  users.users.ncmm = {
    group = "ncmm";
    isSystemUser = true;
  };
  users.groups.ncmm = { };
}
