{
  config,
  pkgs,
  lib,
  LT,
  ...
}:
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

    address =
      [
        "198.19.0.1/32"
        "fdbc:f9dc:67ad:2547::1/128"
      ]
      ++ lib.optionals (LT.this.ltnet.IPv4 != "") [ (LT.this.ltnet.IPv4 + "/32") ]
      ++ lib.optionals (LT.this.ltnet.IPv4Prefix != "") [ (LT.this.ltnet.IPv4Prefix + ".1/32") ]
      ++ lib.optionals (LT.this.dn42.IPv4 != "") [ (LT.this.dn42.IPv4 + "/32") ]
      ++ lib.optionals (LT.this.neonetwork.IPv4 != "") [ (LT.this.neonetwork.IPv4 + "/32") ]
      ++ lib.optionals (LT.this.ltnet.IPv6 != "") [ (LT.this.ltnet.IPv6 + "/128") ]
      ++ lib.optionals (LT.this.ltnet.IPv6Prefix != "") [ (LT.this.ltnet.IPv6Prefix + "::1/128") ]
      ++ lib.optionals (LT.this.dn42.IPv6 != "") [ (LT.this.dn42.IPv6 + "/128") ]
      ++ lib.optionals (LT.this.neonetwork.IPv6 != "") [ (LT.this.neonetwork.IPv6 + "/128") ];
  };

  systemd.services.ltnet-routing-tables = lib.mkIf config.services.zerotierone.enable {
    after = [
      "network.target"
      "zerotierone.service"
    ];
    requires = [
      "network.target"
      "zerotierone.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.iproute2 ];

    script = lib.concatMapStringsSep "\n" (
      n:
      let
        inherit (LT.hosts."${n}") index;
        tableIndex = 10000 + index;
      in
      ''
        ip route add default via 198.18.0.${builtins.toString index} table ${builtins.toString tableIndex}
        ip -6 route add default via fdbc:f9dc:67ad::${builtins.toString index} table ${builtins.toString tableIndex}
      ''
    ) (builtins.attrNames LT.otherHosts);

    postStop = lib.concatMapStringsSep "\n" (
      n:
      let
        inherit (LT.hosts."${n}") index;
        tableIndex = 10000 + index;
      in
      ''
        ip route flush table ${builtins.toString tableIndex}
        ip -6 route flush table ${builtins.toString tableIndex}
      ''
    ) (builtins.attrNames LT.otherHosts);

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "3";
    };
  };
}
