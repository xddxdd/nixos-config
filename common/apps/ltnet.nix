{ pkgs, config, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
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

    addresses = [ ]
      ++ pkgs.lib.optionals (builtins.hasAttr "IPv4Prefix" thisHost.ltnet) [
      {
        addressConfig = {
          Address = thisHost.ltnet.IPv4Prefix + ".1/32";
        };
      }
    ] ++ pkgs.lib.optionals (builtins.hasAttr "IPv4" thisHost.dn42) [
      {
        addressConfig = {
          Address = thisHost.dn42.IPv4 + "/32";
        };
      }
    ] ++ pkgs.lib.optionals (builtins.hasAttr "IPv4" thisHost.neonetwork) [
      {
        addressConfig = {
          Address = thisHost.neonetwork.IPv4 + "/32";
        };
      }
    ] ++ pkgs.lib.optionals (builtins.hasAttr "IPv6Prefix" thisHost.ltnet) [
      {
        addressConfig = {
          Address = thisHost.ltnet.IPv6Prefix + ".1/128";
        };
      }
    ] ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" thisHost.dn42) [
      {
        addressConfig = {
          Address = thisHost.dn42.IPv6 + "/128";
        };
      }
    ] ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" thisHost.neonetwork) [
      {
        addressConfig = {
          Address = thisHost.neonetwork.IPv6 + "/128";
        };
      }
    ];
  };
}
