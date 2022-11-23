{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
{
  systemd.network.netdevs.dummy0 = {
    netdevConfig = {
      Kind = "dummy";
      Name = "dummy0";
    };
  };

  systemd.network.networks.dummy0 = {
    matchConfig = {
      Name = "dummy0";
    };

    networkConfig = {
      IPv6PrivacyExtensions = false;
    };

    address = [ ]
      ++ lib.optionals (LT.this.ltnet.IPv4Prefix != "") [
      (LT.this.ltnet.IPv4Prefix + ".1/32")
    ] ++ lib.optionals (LT.this.dn42.IPv4 != "") [
      (LT.this.dn42.IPv4 + "/32")
    ] ++ lib.optionals (LT.this.neonetwork.IPv4 != "") [
      (LT.this.neonetwork.IPv4 + "/32")
    ] ++ lib.optionals (LT.this.ltnet.IPv6Prefix != "") [
      (LT.this.ltnet.IPv6Prefix + "::1/128")
    ] ++ lib.optionals (LT.this.dn42.IPv6 != "") [
      (LT.this.dn42.IPv6 + "/128")
    ] ++ lib.optionals (LT.this.neonetwork.IPv6 != "") [
      (LT.this.neonetwork.IPv6 + "/128")
    ];
  };
}
