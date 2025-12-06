{
  pkgs,
  lib,
  LT,
  ...
}:
lib.mkIf (LT.this.hasTag LT.tags.ipv4-only) {
  systemd.services.usque-tun-ipv4 = {
    description = "Usque TUN for IPv6 access";
    after = [ "network.target" ];
    requires = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.iproute2 ];

    preStart = ''
      if [ ! -f config.json ]; then
        yes | ${pkgs.nur-xddxdd.usque}/bin/usque register
      fi
    '';

    postStart = ''
      while ! ip addr show usque6 | grep 172.16.0.2; do
        echo "Waiting for Usque to setup IP"
        sleep 1
      done
      ip -6 route add default dev usque6
    '';

    serviceConfig = LT.networkToolHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur-xddxdd.usque}/bin/usque nativetun --interface-name usque6";

      User = "usque";
      Group = "usque";

      StateDirectory = "usque-tun-ipv6";
      WorkingDirectory = "/var/lib/usque-tun-ipv6";
    };
  };

  users.users.usque = {
    group = "usque";
    isSystemUser = true;
  };
  users.groups.usque = { };
}
