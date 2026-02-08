{
  lib,
  pkgs,
  LT,
  ...
}:
{
  systemd.services.oci-arm-host-capacity = {
    script = ''
      ${lib.getExe pkgs.php} ${pkgs.nur-xddxdd.oci-arm-host-capacity}/index.php env 2>&1 | tee log.txt
      grep "Already have an instance" log.txt && exit 1 || exit 0
    '';

    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      StateDirectory = "oci-arm-host-capacity";
      WorkingDirectory = "/var/lib/oci-arm-host-capacity";
    };
  };

  systemd.timers.oci-arm-host-capacity = {
    wantedBy = [ "timers.target" ];
    partOf = [ "oci-arm-host-capacity.service" ];
    timerConfig = {
      OnCalendar = "*:0/2";
      Unit = "oci-arm-host-capacity.service";
    };
  };
}
