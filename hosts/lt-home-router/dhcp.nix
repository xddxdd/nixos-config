{ lib, inputs, ... }:
let
  reservations = import (inputs.secrets + "/dhcp-reservations.nix");
in
{
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [
          "eth0/192.168.0.1"
          "eth0.1/192.168.1.1"
          "eth0.5/192.168.5.1"
        ];
        dhcp-socket-type = "raw";
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 3600 * 6;
      renew-timer = 3600 * 3;
      subnet4 = [
        {
          id = 1;
          subnet = "192.168.0.0/24";
          interface = "eth0";
          pools = [
            { pool = "192.168.0.100 - 192.168.0.249"; }
          ];
          option-data = [
            {
              name = "routers";
              data = "192.168.0.1";
            }
            {
              name = "domain-name-servers";
              data = "192.168.0.1";
            }
          ];
          reservations = reservations.vlan0;
        }
        {
          id = 2;
          subnet = "192.168.1.0/24";
          interface = "eth0";
          pools = [
            { pool = "192.168.1.100 - 192.168.1.249"; }
          ];
          option-data = [
            {
              name = "routers";
              data = "192.168.1.1";
            }
            {
              name = "domain-name-servers";
              data = "192.168.1.1";
            }
          ];
        }
        {
          id = 3;
          subnet = "192.168.5.0/24";
          interface = "eth0";
          pools = [
            { pool = "192.168.5.100 - 192.168.5.249"; }
          ];
          option-data = [
            {
              name = "routers";
              data = "192.168.5.1";
            }
            {
              name = "domain-name-servers";
              data = "192.168.5.1";
            }
          ];
          reservations = reservations.vlan5;
        }
      ];
      valid-lifetime = 3600 * 12;
    };
  };

  systemd.services.kea-dhcp4-server.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = 3;
  };
}
