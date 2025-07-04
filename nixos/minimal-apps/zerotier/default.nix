{
  pkgs,
  lib,
  LT,
  ...
}:
let
  whitelistToBlacklist = pkgs.callPackage ./whitelist_to_blacklist.nix { };

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
    localConf = {
      virtual = lib.mapAttrs' (
        k: v:
        lib.nameValuePair v.zerotier {
          try =
            (lib.optionals (v.public.IPv4 != "") [ "${v.public.IPv4}/9993" ])
            ++ (lib.optionals (v.public.IPv6 != "") [ "${v.public.IPv6}/9993" ])
            ++ (lib.optionals (v.public.IPv6Alt != "") [ "${v.public.IPv6Alt}/9993" ]);
        }
      ) (lib.filterAttrs (k: v: v.zerotier != null) LT.otherHosts);
      settings = {
        interfacePrefixBlacklist = whitelistToBlacklist (
          # Do not try to use network namespaces
          with LT.constants.interfacePrefixes; (builtins.filter (v: v != "ns") (WAN ++ LAN))
        );
        softwareUpdate = "disable";
      };
    };
  };

  systemd.services.zerotierone = {
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
