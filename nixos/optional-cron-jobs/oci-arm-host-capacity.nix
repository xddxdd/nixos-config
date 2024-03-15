{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  systemd.services.oci-arm-host-capacity = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ExecStart = "${pkgs.php}/bin/php ${pkgs.oci-arm-host-capacity}/index.php env";
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
