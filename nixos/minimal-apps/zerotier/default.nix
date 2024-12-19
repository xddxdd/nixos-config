{
  pkgs,
  lib,
  LT,
  ...
}:
let
  whitelistToBlacklist = pkgs.callPackage ./whitelist_to_blacklist.nix { };

  configFile = builtins.toJSON {
    settings = {
      interfacePrefixBlacklist = whitelistToBlacklist (
        # Do not try to use network namespaces
        with LT.constants.interfacePrefixes; (builtins.filter (v: v != "ns") (WAN ++ LAN))
      );
      softwareUpdate = "disable";
    };
  };

  ltnet = "91450bd87b000001";

  zerotier-default = pkgs.writeShellScriptBin "zerotier-default" ''
    if [ -z "$1" ]; then
      echo "Usage: $0 [0/1]"
      exit 1
    fi

    sudo zerotier-cli set ${ltnet} allowDefault=$1
  '';
in
{
  environment.systemPackages = lib.optional (LT.this.hasTag LT.tags.client) zerotier-default;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ ltnet ];
  };

  systemd.services.zerotierone = {
    preStart = ''
      mkdir -p /var/lib/zerotier-one
      cat ${pkgs.writeText "local.conf" configFile} > /var/lib/zerotier-one/local.conf
    '';
    serviceConfig = LT.serviceHarden // {
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
      PrivateDevices = false;
      ProtectClock = false;
      ProtectControlGroups = false;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      SystemCallFilter = [ ];

      StateDirectory = "zerotier-one";
      MemoryMax = "64M";
    };
  };
}
