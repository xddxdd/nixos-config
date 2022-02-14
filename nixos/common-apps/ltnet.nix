{ pkgs, config, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
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
      ++ pkgs.lib.optionals (builtins.hasAttr "IPv4Prefix" LT.this.ltnet) [
      (LT.this.ltnet.IPv4Prefix + ".1/32")
    ] ++ pkgs.lib.optionals (builtins.hasAttr "IPv4" LT.this.dn42) [
      (LT.this.dn42.IPv4 + "/32")
    ] ++ pkgs.lib.optionals (builtins.hasAttr "IPv4" LT.this.neonetwork) [
      (LT.this.neonetwork.IPv4 + "/32")
    ] ++ pkgs.lib.optionals (builtins.hasAttr "IPv6Prefix" LT.this.ltnet) [
      (LT.this.ltnet.IPv6Prefix + "::1/128")
    ] ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" LT.this.dn42) [
      (LT.this.dn42.IPv6 + "/128")
    ] ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" LT.this.neonetwork) [
      (LT.this.neonetwork.IPv6 + "/128")
    ];
  };
}
