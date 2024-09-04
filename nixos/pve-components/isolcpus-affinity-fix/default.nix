{ pkgs, ... }:
{
  systemd.services.isolcpus-affinity-fix = {
    after = [ "pve-cluster.service" ];
    wants = [ "pve-cluster.service" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ util-linux ];

    serviceConfig = {
      ExecStart = "/bin/sh ${./isolcpus-affinity-fix.sh}";
      Restart = "always";
      RestartSec = "3";
    };
  };
}
