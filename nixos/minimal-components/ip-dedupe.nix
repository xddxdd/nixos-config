{ lib, config, ... }:
{
  options.lantian.ip-dedupe = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    description = "Used for deduplication across netns and containers";
  };

  config.lantian.ip-dedupe =
    let
      containersWithPrivateNetworking = lib.filterAttrs (_n: v: v.privateNetwork) config.containers;
      containerIPv4 = lib.mapAttrs' (
        n: v: lib.nameValuePair v.localAddress "containers.${n}"
      ) containersWithPrivateNetworking;
      containerIPv6 = lib.mapAttrs' (
        n: v: lib.nameValuePair v.localAddress6 "containers.${n}"
      ) containersWithPrivateNetworking;
    in
    containerIPv4 // containerIPv6;
}
