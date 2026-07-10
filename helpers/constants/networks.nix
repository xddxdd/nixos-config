{ lib, inputs, ... }:
{
  china-mainland =
    let
      cnData = lib.importJSON (inputs.country-ip-blocks + "/country/cn/aggregated.json");
    in
    {
      IPv4 = cnData.prefixes.ipv4;
      IPv6 = cnData.prefixes.ipv6;
    };

  dn42 = {
    IPv4 = [
      "172.20.0.0/14"
      "172.31.0.0/16"
      "10.0.0.0/8"
    ];

    IPv6 = [ "fd00::/8" ];

    region = {
      Europe = 41;
      North-America-E = 42;
      North-America-C = 43;
      North-America-W = 44;
      Central-America = 45;
      South-America-E = 46;
      South-America-W = 47;
      Africa-N = 48;
      Africa-S = 49;
      Asia-S = 50;
      Asia-SE = 51;
      Asia-E = 52;
      Pacific-Oceania = 53;
      Antarctica = 54;
      Asia-N = 55;
      Asia-W = 56;
      Central-Asia = 57;
    };
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
