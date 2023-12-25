{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  whitelistToBlacklist = wl:
    lib.splitString "\n" (builtins.readFile (pkgs.runCommandLocal "wl2bl.out" {} ''
      ${pkgs.python3Minimal}/bin/python3 ${./whitelist_to_blacklist.py} ${lib.escapeShellArgs wl} > $out
    ''));

  configFile = builtins.toJSON {
    settings = {
      interfacePrefixBlacklist =
        whitelistToBlacklist
        (with LT.constants.interfacePrefixes; (WAN ++ LAN));
      softwareUpdate = "disable";
    };
  };
in {
  services.zerotierone = {
    enable = true;
    joinNetworks = ["af78bf9436f191fd"];
  };

  systemd.services.zerotierone = {
    preStart = ''
      mkdir -p /var/lib/zerotier-one
      cat ${pkgs.writeText "local.conf" configFile} > /var/lib/zerotier-one/local.conf
    '';
    serviceConfig =
      LT.serviceHarden
      // {
        AmbientCapabilities = ["CAP_NET_ADMIN"];
        CapabilityBoundingSet = ["CAP_NET_ADMIN"];
        PrivateDevices = false;
        ProtectClock = false;
        ProtectControlGroups = false;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
        SystemCallFilter = [];

        StateDirectory = "zerotier-one";
        MemoryMax = "64M";
      };
  };
}
