{
  pkgs,
  lib,
  LT,
  ...
}:
{
  systemd.services.bgp-flowspec = {
    enable = false;
    description = "BGP Flowspec Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.nftables
    ];

    serviceConfig = LT.networkToolHarden // {
      Restart = "always";
      RestartSec = "5";

      ExecStart = builtins.concatStringsSep " " [
        (lib.getExe pkgs.nur-xddxdd.hack3ric-flow)
        "run"
        "--bind [::1]:${LT.portStr.Hack3ricFlow}"
        "--local-as 65000"
        "--remote-as 4242422547"
        "--allowed-ips ::1/128"
      ];
    };
  };
}
