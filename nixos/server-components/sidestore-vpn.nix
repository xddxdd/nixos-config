{
  pkgs,
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
      ExecStart = "${pkgs.nur-xddxdd.sidestore-vpn}/bin/sidestore-vpn";
      DynamicUser = true;
    };
  };
}
