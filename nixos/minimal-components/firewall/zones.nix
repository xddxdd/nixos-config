{
  lib,
  LT,
  config,
  ...
}:
let
  inherit (LT.constants) interfacePrefixes;

  portEntryType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum [
          "local"
          "forward"
          "reject"
        ];
        description = ''
          What to do with traffic to this port arriving from the zone:
          - "local": accept it on this host.
          - "forward": DNAT it to ipv4 and/or ipv6.
          - "reject": reject it.
        '';
      };
      ipv4 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "IPv4 DNAT target for type = \"forward\".";
      };
      ipv6 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "IPv6 DNAT target for type = \"forward\".";
      };
    };
  };

  zoneType = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      priority = lib.mkOption {
        type = lib.types.int;
        default = 100;
        description = ''
          Dispatch order; lower numbers match first. A subzone uses a lower
          number than its parent so it can special-case traffic the parent
          would otherwise claim.
        '';
      };
      interfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Interface name patterns; a trailing * is appended to each unless interfaceWildcard is false.";
      };
      interfaceWildcard = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Append a trailing * to each interface name. Disable for exact interface names.";
      };
      sourceIPv4 = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "IPv4 source CIDRs belonging to this zone.";
      };
      sourceIPv6 = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "IPv6 source CIDRs belonging to this zone.";
      };
      sourceIPv4Exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "IPv4 source CIDRs carved out of this zone's source match, so they fall through to a later zone.";
      };
      sourceIPv6Exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "IPv6 source CIDRs carved out of this zone's source match, so they fall through to a later zone.";
      };
      tcpPorts = lib.mkOption {
        type = lib.types.attrsOf portEntryType;
        default = { };
        description = "TCP ports of traffic from this zone destined to localhost.";
      };
      udpPorts = lib.mkOption {
        type = lib.types.attrsOf portEntryType;
        default = { };
        description = "UDP ports of traffic from this zone destined to localhost.";
      };
      forwardTo = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Zones this zone may forward traffic to.";
      };
      inputPolicy = lib.mkOption {
        type = lib.types.enum [
          "accept"
          "reject"
          "return"
        ];
        default = "reject";
        description = ''
          Terminal policy of the zone input chain. "return" falls through to
          the next matching zone, which is how a source-only subzone blocks a
          subset of ports and leaves the rest to its parent.
        '';
      };
      allowEphemeral = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Accept the local ephemeral port range.";
      };
      allowedIpProtocols = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [ ];
        description = "IPv4 protocol numbers accepted from this zone (e.g. 41 for SIT).";
      };
    };
  };

  zoneId = name: lib.toUpper (lib.replaceStrings [ "-" "." ] [ "_" "_" ] name);

  enabledZones = lib.filterAttrs (_: z: z.enable) config.lantian.firewall.zones;
  sortedZones = lib.sort (a: b: a.priority < b.priority) (
    lib.mapAttrsToList (name: z: z // { zoneName = name; }) enabledZones
  );

  ephemeralPortRange = "${LT.portStr.Ephemeral.Start}-${LT.portStr.Ephemeral.End}";

  portRules =
    proto: ports:
    lib.concatMap (
      { port, entry }:
      if entry.type == "local" then
        [ "${proto} dport ${port} accept" ]
      else if entry.type == "reject" then
        [
          (
            if proto == "tcp" then
              "${proto} dport ${port} reject with tcp reset"
            else
              "${proto} dport ${port} reject with icmpx type port-unreachable"
          )
        ]
      else
        [ ]
    ) (lib.mapAttrsToList (port: entry: { inherit port entry; }) ports);

  inputRules =
    z:
    [ "meta l4proto icmp accept" ]
    ++ [ "meta l4proto icmpv6 accept" ]
    ++ lib.optionals z.allowEphemeral [
      "tcp dport ${ephemeralPortRange} accept"
      "udp dport ${ephemeralPortRange} accept"
    ]
    ++ map (n: "ip protocol ${builtins.toString n} accept") z.allowedIpProtocols
    ++ portRules "tcp" z.tcpPorts
    ++ portRules "udp" z.udpPorts
    ++ [
      (
        if z.inputPolicy == "accept" then
          "accept"
        else if z.inputPolicy == "return" then
          "return"
        else
          "reject with icmpx type admin-prohibited"
      )
    ];

  forwardTargets =
    z:
    builtins.filter (
      t: builtins.hasAttr t enabledZones && enabledZones.${t}.interfaces != [ ]
    ) z.forwardTo;

  forwardRules =
    z:
    map (target: "oifname @ZONE_${zoneId target}_INTERFACES accept") (forwardTargets z)
    ++ [ "reject with icmpx type admin-prohibited" ];

  hasForward =
    z:
    lib.any (e: e.type == "forward") (builtins.attrValues z.tcpPorts ++ builtins.attrValues z.udpPorts);

  preroutingRules =
    z:
    lib.flatten (
      lib.concatMap
        (
          proto:
          lib.mapAttrsToList (
            port: entry:
            lib.optionals (entry.type == "forward") (
              lib.optional (
                entry.ipv4 != null
              ) "fib daddr type local ${proto} dport ${port} dnat ip to ${entry.ipv4}"
              ++ lib.optional (
                entry.ipv6 != null
              ) "fib daddr type local ${proto} dport ${port} dnat ip6 to [${entry.ipv6}]"
            )
          ) (if proto == "tcp" then z.tcpPorts else z.udpPorts)
        )
        [
          "tcp"
          "udp"
        ]
    )
    ++ [ "return" ];

  dispatchRules =
    hook: filterFn:
    lib.concatMap (
      z:
      let
        id = zoneId z.zoneName;
        iface = "iifname @ZONE_${id}_INTERFACES";
        v4 = "ip saddr @ZONE_${id}_IPV4${
          lib.optionalString (z.sourceIPv4Exclude != [ ]) " ip saddr != @ZONE_${id}_EXCLUDE_IPV4"
        }";
        v6 = "ip6 saddr @ZONE_${id}_IPV6${
          lib.optionalString (z.sourceIPv6Exclude != [ ]) " ip6 saddr != @ZONE_${id}_EXCLUDE_IPV6"
        }";
        hasIface = z.interfaces != [ ];
        # A zone matches only when every dimension it declares matches, so a
        # zone listing both interfaces and sources is scoped to that
        # interface/source pair instead of either one alone.
        rule = match: "${lib.concatStringsSep " " match} jump ZONE_${id}_${hook}";
      in
      if hasIface && z.sourceIPv4 == [ ] && z.sourceIPv6 == [ ] then
        [ (rule [ iface ]) ]
      else
        lib.optional (z.sourceIPv4 != [ ]) (rule (lib.optional hasIface iface ++ [ v4 ]))
        ++ lib.optional (z.sourceIPv6 != [ ]) (rule (lib.optional hasIface iface ++ [ v6 ]))
    ) (builtins.filter filterFn sortedZones);
in
{
  options.lantian.firewall.zones = lib.mkOption {
    type = lib.types.attrsOf zoneType;
    default = { };
    description = ''
      Zone-based firewall policy. Each zone matches traffic by interface
      and/or source address, and declares what that traffic may reach on
      this host (tcpPorts/udpPorts), where it may be forwarded (forwardTo),
      and what happens to everything else (inputPolicy). Zones are matched
      in ascending priority order, so a subzone can special-case traffic
      before its parent zone.
    '';
  };

  config = {
    lantian.firewall.zones = {
      WAN = {
        priority = 100;
        interfaces = interfacePrefixes.WAN ++ interfacePrefixes.OVERLAY;
        allowEphemeral = true;
        # DHCP client replies arrive on the WAN link before the interface has
        # an address, so they never match the ephemeral port range.
        udpPorts = {
          "${LT.portStr.DHCP.Client}" = {
            type = "local";
          };
          "${LT.portStr.DHCPv6.Client}" = {
            type = "local";
          };
        };
      };
      DN42 = {
        priority = 20;
        interfaces = interfacePrefixes.DN42;
        sourceIPv4 = LT.constants.dn42.IPv4 ++ LT.constants.neonetwork.IPv4;
        sourceIPv6 = LT.constants.dn42.IPv6 ++ LT.constants.neonetwork.IPv6;
        # Our own DN42/NeoNetwork space is trusted like LAN, not treated as
        # foreign DN42.
        sourceIPv4Exclude = LT.constants.ltnet.IPv4;
        sourceIPv6Exclude = LT.constants.ltnet.IPv6;
        forwardTo = [ "DN42" ];
      };
      LAN = {
        priority = 30;
        # A firewalled host sits behind an upstream firewall, so its WAN
        # interfaces are trusted like LAN. They stay in the WAN zone too,
        # so sources outside the LAN IP ranges still get WAN policy.
        interfaces = interfacePrefixes.LAN ++ lib.optionals LT.this.firewalled interfacePrefixes.WAN;
        sourceIPv4 = lib.unique (LT.constants.reserved.IPv4 ++ LT.constants.ltnet.IPv4);
        sourceIPv6 = lib.unique (
          LT.constants.reserved.IPv6 ++ LT.this.interconnect.internalIPv6Ranges ++ LT.constants.ltnet.IPv6
        );
        inputPolicy = "accept";
        forwardTo = [
          "WAN"
          "DN42"
          "LAN"
        ];
      };
      WAN_CN_BLOCKED = {
        priority = 50;
        sourceIPv4 = LT.constants.china-mainland.IPv4;
        sourceIPv6 = LT.constants.china-mainland.IPv6;
        inputPolicy = "return";
        tcpPorts."20000-23999" = {
          type = "reject";
        };
        udpPorts."20000-23999" = {
          type = "reject";
        };
      };
    };
    lantian.firewall.ipsets = lib.mkMerge (
      lib.mapAttrsToList (
        name: z:
        let
          id = zoneId name;
        in
        lib.mkMerge [
          (lib.mkIf (z.interfaces != [ ]) {
            "ZONE_${id}_INTERFACES" = {
              type = "ifname";
              flags = [
                "constant"
                "interval"
              ];
              elements = map (p: if z.interfaceWildcard then p + "*" else p) z.interfaces;
            };
          })
          (lib.mkIf (z.sourceIPv4 != [ ]) {
            "ZONE_${id}_IPV4" = {
              type = "ipv4_addr";
              flags = [
                "constant"
                "interval"
              ];
              autoMerge = true;
              elements = z.sourceIPv4;
            };
          })
          (lib.mkIf (z.sourceIPv6 != [ ]) {
            "ZONE_${id}_IPV6" = {
              type = "ipv6_addr";
              flags = [
                "constant"
                "interval"
              ];
              autoMerge = true;
              elements = z.sourceIPv6;
            };
          })
          (lib.mkIf (z.sourceIPv4Exclude != [ ]) {
            "ZONE_${id}_EXCLUDE_IPV4" = {
              type = "ipv4_addr";
              flags = [
                "constant"
                "interval"
              ];
              autoMerge = true;
              elements = z.sourceIPv4Exclude;
            };
          })
          (lib.mkIf (z.sourceIPv6Exclude != [ ]) {
            "ZONE_${id}_EXCLUDE_IPV6" = {
              type = "ipv6_addr";
              flags = [
                "constant"
                "interval"
              ];
              autoMerge = true;
              elements = z.sourceIPv6Exclude;
            };
          })
        ]
      ) enabledZones
    );

    lantian.firewall.chains = lib.mkMerge (
      (lib.mapAttrsToList (
        name: z:
        let
          id = zoneId name;
        in
        lib.mkMerge [
          {
            "ZONE_${id}_INPUT".rules = [
              {
                text = lib.concatStringsSep "\n" (inputRules z);
              }
            ];
          }
          (lib.mkIf (z.interfaces != [ ]) {
            "ZONE_${id}_FORWARD".rules = [
              {
                text = lib.concatStringsSep "\n" (forwardRules z);
              }
            ];
          })
          (lib.mkIf (hasForward z) {
            "ZONE_${id}_PREROUTING".rules = [
              {
                text = lib.concatStringsSep "\n" (preroutingRules z);
              }
            ];
          })
        ]
      ) enabledZones)
      ++ [
        {
          FILTER_INPUT.rules = [
            {
              priority = LT.firewallPriorities.early;
              text = ''iifname "lo" accept'';
            }
            {
              priority = LT.firewallPriorities.service;
              text = lib.concatStringsSep "\n" (dispatchRules "INPUT" (_: true));
            }
          ];
          FILTER_FORWARD.rules = [
            {
              priority = LT.firewallPriorities.service;
              text = lib.concatStringsSep "\n" (dispatchRules "FORWARD" (z: z.interfaces != [ ]));
            }
          ];
          NAT_PREROUTING.rules = [
            {
              priority = LT.firewallPriorities.early;
              text = lib.concatStringsSep "\n" (dispatchRules "PREROUTING" hasForward);
            }
          ];
        }
      ]
    );

    assertions =
      lib.mapAttrsToList (name: z: {
        assertion = lib.all (e: e.type != "forward" || e.ipv4 != null || e.ipv6 != null) (
          builtins.attrValues z.tcpPorts ++ builtins.attrValues z.udpPorts
        );
        message = "lantian.firewall.zones.${name}: forward port entries need ipv4 and/or ipv6";
      }) enabledZones
      ++ lib.mapAttrsToList (name: z: {
        assertion = lib.all (t: builtins.hasAttr t config.lantian.firewall.zones) z.forwardTo;
        message = "lantian.firewall.zones.${name}: forwardTo references an unknown zone";
      }) enabledZones;
  };
}
