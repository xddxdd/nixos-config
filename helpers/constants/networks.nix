{ lib, inputs, ... }:
{
  china-mainland =
    let
      parseCidrList =
        file:
        (builtins.filter (
          l:
          lib.stringLength l != 0
          && !(lib.hasPrefix "#" l)
          # Do not trust country from HENET tunnel
          && !(lib.hasPrefix "2001:470:" l)
          && !(lib.hasPrefix "2001:0470:" l)
        ) (lib.splitString "\n" (builtins.readFile file)));
    in
    {
      IPv4 = parseCidrList inputs.ipcountry-cn-ipv4.outPath;
      IPv6 = parseCidrList inputs.ipcountry-cn-ipv6.outPath;
    };

  dn42 = {
    IPv4 = [
      "172.20.0.0/14"
      "172.31.0.0/16"
      "10.0.0.0/8"
    ];

    IPv6 = [ "fd00::/8" ];
  };

  neonetwork = {
    IPv4 = [ "10.127.0.0/16" ];

    IPv6 = [ "fd10:127::/32" ];
  };

  reserved = {
    IPv4 = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.0.0.0/24"
      "192.0.2.0/24"
      "192.168.0.0/16"
      "198.18.0.0/15"
      "198.51.100.0/24"
      "203.0.113.0/24"
      "233.252.0.0/24"
      "240.0.0.0/4"
    ];

    IPv6 = [
      "2001:2::/48"
      "2001:20::/28"
      "2001:db8::/32"
      "64:ff9b::/96"
      "64:ff9b:1::/48"
      "fc00::/7"
    ];
  };
}
