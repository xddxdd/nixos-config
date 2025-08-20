{
  pkgs,
  ...
}:
{
  systemd.services.usque-tun-ipv4 = {
    description = "Usque TUN for IPv4 access";
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
      while ! ip addr show usque4 | grep 172.16.0.2; do
        echo "Waiting for Usque to setup IPv4"
        sleep 1
      done
      ip route add default dev usque4
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur-xddxdd.usque}/bin/usque nativetun --interface-name usque4 --ipv6";

      StateDirectory = "usque-tun-ipv4";
      WorkingDirectory = "/var/lib/usque-tun-ipv4";
    };
  };
}
