{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  boot.extraModulePackages = with config.boot.kernelPackages; [
    qdma
    xdma
  ];

  systemd.services.xvcd = {
    description = "Xilinx Virtual Cable Daemon";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${lib.getExe pkgs.nur-xddxdd.xvcd} -P 0x6015";
      Restart = "always";
      RestartSec = "3";
      # Talks to USB JTAG cables
      PrivateDevices = false;
      BindReadOnlyPaths = [ "/etc/localtime" ];
    };

    confinement = { enable = true; fullUnit = true; };
  };
}
