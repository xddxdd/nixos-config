{ pkgs, LT, ... }:
{
  systemd.services.bgp-flowspec = {
    enable = false;
    description = "BGP Flowspec Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.nftables
    ];

    script = ''
      exec ${pkgs.nur-xddxdd.hack3ric-flow}/bin/flow run \
        --bind [::1]:${LT.portStr.Hack3ricFlow} \
        --local-as 65000 \
        --remote-as 4242422547 \
        --allowed-ips ::1/128
    '';

    serviceConfig = LT.networkToolHarden // {
      Restart = "always";
      RestartSec = "5";
    };
  };
}
