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
      valid-lifetime = 3600 * 12;

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
    };
  };

  services.kea.dhcp6 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [
          "eth0/2001:470:e997::1"
          "eth0.1/2001:470:e997:1::1"
          "eth0.5/2001:470:e997:5::1"
        ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp6.leases";
        persist = true;
        type = "memfile";
      };

      rebind-timer = 3600 * 6;
      renew-timer = 3600 * 3;
      valid-lifetime = 3600 * 12;

      subnet6 = [
        # {
        #   id = 1;
        #   subnet = "2001:470:e997::/64";
        #   interface = "eth0";
        #   pools = [
        #     { pool = "2001:470:e997::ff00 - 2001:470:e997::ffff"; }
        #   ];
        #   option-data = [
        #     {
        #       name = "dns-servers";
        #       data = "2001:470:e997::1";
        #     }
        #   ];
        # }
        {
          id = 2;
          subnet = "2001:470:e997:1::/64";
          interface = "eth0.1";
          pools = [
            { pool = "2001:470:e997:1::ff00 - 2001:470:e997:1::ffff"; }
          ];
          option-data = [
            {
              name = "dns-servers";
              data = "2001:470:e997:1::1";
            }
          ];
        }
        {
          id = 3;
          subnet = "2001:470:e997:5::/64";
          interface = "eth0.5";
          pools = [
            { pool = "2001:470:e997:5::ff00 - 2001:470:e997:5::ffff"; }
          ];
          option-data = [
            {
              name = "dns-servers";
              data = "2001:470:e997:5::1";
            }
          ];
        }
      ];
    };
  };

  systemd.services.kea-dhcp4-server.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = 3;
  };
  systemd.services.kea-dhcp6-server.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = 3;
  };
}
