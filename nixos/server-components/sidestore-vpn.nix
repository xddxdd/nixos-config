{
  pkgs,
  lib,
  LT,
  ...
}:
{
  systemd.services.sidestore-vpn = {
    description = "SideStore VPN";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = LT.networkToolHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${lib.getExe pkgs.nur-xddxdd.sidestore-vpn}";
      DynamicUser = true;
    };
  };
}
