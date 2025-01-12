{
  pkgs,
  ...
}:
{
  systemd.services.xvcd = {
    description = "Xilinx Virtual Cable Daemon";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.nur-xddxdd.xvcd}/bin/xvcd -P 0x6015";
      Restart = "always";
      RestartSec = "3";
    };
  };
}
