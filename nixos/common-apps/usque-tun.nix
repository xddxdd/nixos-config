{
  pkgs,
  lib,
  LT,
  ...
}:
lib.mkIf (LT.this.hasTag LT.tags.ipv4-only || LT.this.hasTag LT.tags.ipv6-only) {
  systemd.services.usque-tun = {
    description = "Usque Tunnel";
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
      while ! ip addr show usque | grep 172.16.0.2; do
        echo "Waiting for Usque to setup IP"
        sleep 1
      done
    ''
    + lib.optionalString (LT.this.hasTag LT.tags.ipv4-only) ''
      ip -6 route add default dev usque
    ''
    + lib.optionalString (LT.this.hasTag LT.tags.ipv6-only) ''
      ip route add default dev usque
    '';

    serviceConfig = LT.networkToolHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart =
        "${pkgs.nur-xddxdd.usque}/bin/usque nativetun --interface-name usque"
        + (lib.optionalString (LT.this.hasTag LT.tags.ipv6-only) " --ipv6");

      User = "usque";
      Group = "usque";

      StateDirectory = "usque-tun";
      WorkingDirectory = "/var/lib/usque-tun";
    };
  };

  users.users.usque = {
    group = "usque";
    isSystemUser = true;
  };
  users.groups.usque = { };
}
