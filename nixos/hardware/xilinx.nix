{
  LT,
  pkgs,
  lib,
  config,
  ...
}:
{
  boot.extraModulePackages = with config.boot.kernelPackages; [
    qdma
    xdma
  ];

  lantian.firewall.zones = {
    LAN.tcpPorts."${LT.portStr.Xvcd}".type = "local";
  };

  systemd.services.xvcd = {
    description = "Xilinx Virtual Cable Daemon";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.nur-xddxdd.xvcd} -P 0x6015";
      Restart = "always";
      RestartSec = "3";
    };
  };
}
