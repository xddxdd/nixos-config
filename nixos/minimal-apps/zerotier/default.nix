{
  pkgs,
  lib,
  LT,
  ...
}:
let
  whitelistToBlacklist = pkgs.callPackage ./whitelist_to_blacklist.nix { };
  calculateMac = pkgs.callPackage ./mac-calculator.nix { };

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
            (lib.optionals (v.public.IPv4 != null) [ "${v.public.IPv4}/9993" ])
            ++ (lib.optionals (v.public.IPv6 != null) [ "${v.public.IPv6}/9993" ])
            ++ (lib.optionals (v.public.IPv6Alt != null) [ "${v.public.IPv6Alt}/9993" ]);
        }
      ) (lib.filterAttrs (k: v: v.zerotier != null) LT.otherHosts);
      settings = {
        interfacePrefixBlacklist = whitelistToBlacklist (
          # Do not try to use network namespaces
          with LT.constants.interfacePrefixes; (builtins.filter (v: v != "ns") (WAN ++ LAN))
        );
        softwareUpdate = "disable";
        portMappingEnabled = LT.this.firewalled || LT.this.public.IPv4 == null;
        allowTcpFallbackRelay = false;
      };
    };
  };

  systemd.services.zerotierone = {
    preStart = ''
      rm -rf /var/lib/zerotier-one/peers.d
    ''
    + lib.optionalString (LT.this.hasTag LT.tags.server) ''
      cat > /var/lib/zerotier-one/networks.d/${ltnet}.local.conf <<EOF
      allowManaged=0
      allowGlobal=0
      allowDefault=0
      allowDNS=0
      EOF
    '';

    serviceConfig = LT.networkToolHarden // {
      StateDirectory = "zerotier-one";
      MemoryMax = "64M";
      Nice = "-20";
    };
  };

  systemd.network.networks."99-zerotier" = lib.mkIf (LT.this.hasTag LT.tags.server) {
    matchConfig.Name = "ztje7axwd2";
    address = [
      "198.18.0.${builtins.toString LT.this.index}/24"
      "fdbc:f9dc:67ad::${builtins.toString LT.this.index}/64"
    ];
    networkConfig = {
      LinkLocalAddressing = "no";
    };
    routes = lib.flatten (
      lib.mapAttrsToList (
        n: v:
        let
          i = builtins.toString v.index;
          routes = builtins.filter (
            route: !lib.hasPrefix "198.18.0." route && !lib.hasPrefix "fdbc:f9dc:67ad::" route
          ) v._routes;
        in
        builtins.map (r: {
          Destination = r;
          Gateway = if lib.hasInfix ":" r then "fdbc:f9dc:67ad::${i}" else "198.18.0.${i}";
        }) routes
      ) (LT.otherHostsWithoutTag LT.tags.server)
    );

    extraConfig = lib.concatMapAttrsStringSep "\n" (
      n: v:
      lib.concatMapStringsSep "\n" (ip: ''
        [Neighbor]
        # ${v.name}
        Address=${ip}
        LinkLayerAddress=${calculateMac ltnet n}
      '') v.ipAssignments
    ) LT.zerotier.hosts;
  };
}
