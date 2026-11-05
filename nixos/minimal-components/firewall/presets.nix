{
  lib,
  LT,
  config,
  ...
}:
let
  interfaceSetsEnabled = config.lantian.firewall.presets.interface-sets.enable;

  # Interface match expressions may reference INTERFACE_* sets (e.g.
  # "@INTERFACE_WAN"); those are only declared when the interface-sets preset
  # is enabled.
  ifaceRefsOk = list: lib.all (i: !(lib.hasPrefix "@" i) || interfaceSetsEnabled) list;
in
{
  options.lantian.firewall.presets = {

    drop-timestamp-icmp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Drop ICMP timestamp request/reply packets.";
      };
    };

    block-zerotier-mdns = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Block mDNS (port 5353) on ZeroTier interfaces.";
      };
    };

    interface-sets = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Declare the INTERFACE_WAN/OVERLAY/DN42/LAN ifname sets from LT.constants.interfacePrefixes.";
      };
    };

    public-firewall = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = !LT.this.firewalled;
        description = "Reject configured service ports on WAN/overlay interfaces (PUBLIC_INPUT/PUBLIC_FORWARD chains).";
      };
      firewalledPorts = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [ ];
        description = "Ports rejected for traffic arriving from public interfaces; enabled services contribute their own ports.";
      };
      inputInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "@INTERFACE_WAN"
          "@INTERFACE_OVERLAY"
        ];
        description = "Interface match expressions jumped to PUBLIC_INPUT.";
      };
      forwardInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "@INTERFACE_WAN"
          "@INTERFACE_OVERLAY"
        ];
        description = "Interface match expressions jumped to PUBLIC_FORWARD.";
      };
      allowLanSources = lib.mkOption {
        type = lib.types.bool;
        default = LT.this.hasTag LT.tags.lan-access;
        description = "Let reserved (LAN) source addresses bypass the public firewall.";
      };
    };

    block-cn-ports = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Reject China-mainland sources on CN_FIREWALLED_PORTS (DN42 range plus ports contributed by other modules, e.g. the game accelerator).";
      };
    };

    dn42 = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "DN42/NeoNetwork input and forward restrictions plus SNAT for LAN clients, when this host has DN42/NeoNetwork addresses.";
      };
    };

    sidestore = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Rewrite SideStore's direct connection address (10.7.0.1) back to the client.";
      };
    };

    kms-redirect = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Redirect KMS requests to the ltnet KMS server.";
      };
      targetIPv4 = lib.mkOption {
        type = lib.types.str;
        default = "198.19.0.252";
        description = "KMS server IPv4 address.";
      };
      targetIPv6 = lib.mkOption {
        type = lib.types.str;
        default = "fdbc:f9dc:67ad:2547::1688";
        description = "KMS server IPv6 address.";
      };
      lanInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "@INTERFACE_LAN" ];
        description = "Interface match expressions the redirect applies to.";
      };
    };

    ltnet-fallback-snat = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "SNAT traffic to ltnet addresses (198.18.0.200-255) reserved for devices without BGP sessions.";
      };
    };

    masquerade = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Masquerade traffic leaving the reserved (LAN) address space.";
      };
    };

    dns-redirect = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Hijack locally-destined DNS (port 53) into a network namespace running CoreDNS.";
      };
      netns = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Network namespace (under lantian.netns) receiving the DNS traffic.";
      };
      lanInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Interface match expressions the redirect applies to; empty means all interfaces.";
      };
    };

    block-ipv6 = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Drop all IPv6 traffic on the given interfaces.";
      };
      interfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Interface match expressions.";
      };
    };

    vlan-isolate = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Isolate VLANs on a shared interface from each other, allowing only the configured exceptions.";
      };
      interfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "eth0*" ];
        description = "Interface match expressions whose intra-interface traffic is isolated.";
      };
      allowTcpPorts = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [
          9993
          22000
          111
          2049
        ];
        description = "Allowed TCP ports (ZeroTier, Syncthing, NFS).";
      };
      allowUdpPorts = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [
          9993
          22000
          111
          2049
        ];
        description = "Allowed UDP ports (ZeroTier, Syncthing, NFS).";
      };
      allowDestIPs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Destination IPv4 addresses reachable across VLANs.";
      };
      allowFromInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Source interfaces allowed to reach everything (e.g. user VLAN).";
      };
      allowInterfacePairs = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              from = lib.mkOption {
                type = lib.types.str;
                description = "Source interface.";
              };
              to = lib.mkOption {
                type = lib.types.str;
                description = "Destination interface.";
              };
            };
          }
        );
        default = [ ];
        description = "Source/destination interface pairs allowed to talk (e.g. homelab VLAN to IoT VLAN).";
      };
    };

    port-forward = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Port forwarding through structured DNAT entries or the NAT_PORT_FORWARD chain, including hairpin NAT.";
      };
      wanInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "WAN interface match expressions whose locally-destined traffic enters NAT_PORT_FORWARD.";
      };
      hairpinInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "LAN interface match expressions getting hairpin NAT (port forward for LAN clients).";
      };
      hairpinMasqueradeInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Interfaces masqueraded for hairpin NAT in NAT_POSTROUTING.";
      };
      forwards = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              destination = lib.mkOption {
                type = lib.types.enum [
                  "local"
                  "public"
                  "address"
                ];
                description = ''
                  Destination match of the forwarded traffic:
                  - "local": fib daddr type local (any address of this host)
                  - "public": this host's public IPv4/IPv6 addresses (LT.this.public)
                  - "address": explicit addresses from destinationIPv4/destinationIPv6
                '';
              };
              destinationIPv4 = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Explicit IPv4 destination addresses, used when destination = \"address\".";
              };
              destinationIPv6 = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Explicit IPv6 destination addresses, used when destination = \"address\".";
              };
              interfaces = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Optional iifname match expressions.";
              };
              protocols = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.enum [
                    "tcp"
                    "udp"
                  ]
                );
                default = [
                  "tcp"
                  "udp"
                ];
                description = "Protocols to forward; ignored when ports is null.";
              };
              ports = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  nftables port spec (e.g. "80", "31080-31089", "{ 80, 443 }");
                  null forwards all ports and protocols.
                '';
              };
              targetIPv4 = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  DNAT target for IPv4 traffic, as passed to "dnat ip to"
                  (may include a ":port" suffix). Rules are only generated
                  when this is set.
                '';
              };
              targetIPv6 = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  DNAT target for IPv6 traffic, as passed to "dnat ip6 to"
                  (may include a ":port" suffix; brackets are added
                  automatically when absent).
                '';
              };
            };
          }
        );
        default = [ ];
        description = "Structured port forwarding entries rendered into NAT_PREROUTING via the chain's DNAT option.";
      };
    };

    masquerade-outbound = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Masquerade all IPv4 traffic leaving via any interface except the excluded ones.";
      };
      excludeInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Interface match expressions excluded from masquerading.";
      };
    };

    block-outbound-src-ports = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Drop locally-generated packets whose source port is a firewalled port (PUBLIC_OUTPUT chain).";
      };
      outputInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Interface match expressions jumped to PUBLIC_OUTPUT.";
      };
    };

  };

  config = lib.mkMerge [
    (lib.mkIf config.lantian.firewall.presets.drop-timestamp-icmp.enable {
      lantian.firewall.chains.FILTER_INPUT.rules = [
        {
          priority = LT.firewallPriorities.early;
          text = ''
            meta l4proto icmp icmp type timestamp-reply drop
            meta l4proto icmp icmp type timestamp-request drop
          '';
        }
      ];
    })

    (lib.mkIf config.lantian.firewall.presets.block-zerotier-mdns.enable {
      lantian.firewall.chains.FILTER_INPUT.rules = [
        {
          priority = LT.firewallPriorities.preService;
          text = ''
            iifname "zt*" udp sport 5353 reject
            iifname "zt*" udp dport 5353 reject
          '';
        }
      ];
      lantian.firewall.chains.FILTER_OUTPUT.rules = [
        {
          priority = LT.firewallPriorities.early;
          text = ''
            oifname "zt*" udp sport 5353 reject
            oifname "zt*" udp dport 5353 reject
          '';
        }
      ];
    })

    (lib.mkIf config.lantian.firewall.presets.interface-sets.enable {
      lantian.firewall.ipsets = lib.mapAttrs' (
        k: v:
        lib.nameValuePair "INTERFACE_${k}" {
          type = "ifname";
          flags = [
            "constant"
            "interval"
          ];
          elements = map (p: p + "*") v;
        }
      ) LT.constants.interfacePrefixes;
    })

    (
      let
        cfg = config.lantian.firewall.presets.public-firewall;
      in
      lib.mkMerge [
        (lib.mkIf cfg.enable {
          lantian.firewall.ipsets.PUBLIC_FIREWALLED_PORTS = {
            type = "inet_service";
            flags = [ "constant" ];
            elements = cfg.firewalledPorts;
          };
          lantian.firewall.chains.PUBLIC_INPUT.rules =
            (lib.optionals cfg.allowLanSources [
              {
                priority = LT.firewallPriorities.early;
                text = ''
                  ip saddr @RESERVED_IPV4 return
                  ip6 saddr @RESERVED_IPV6 return
                '';
              }
            ])
            ++ [
              {
                priority = LT.firewallPriorities.service;
                text = ''
                  tcp dport @PUBLIC_FIREWALLED_PORTS reject with tcp reset
                  udp dport @PUBLIC_FIREWALLED_PORTS reject with icmpx type port-unreachable
                '';
              }
              {
                priority = LT.firewallPriorities.terminal;
                text = "return";
              }
            ];
        })
        (lib.mkIf (cfg.enable && cfg.forwardInterfaces != [ ]) {
          lantian.firewall.chains.PUBLIC_FORWARD.rules =
            (lib.optionals cfg.allowLanSources [
              {
                priority = LT.firewallPriorities.early;
                text = ''
                  ip saddr @RESERVED_IPV4 return
                  ip6 saddr @RESERVED_IPV6 return
                '';
              }
            ])
            ++ [
              {
                priority = LT.firewallPriorities.terminal;
                text = "reject with icmpx type admin-prohibited";
              }
            ];
        })
        (lib.mkIf (cfg.enable && ifaceRefsOk cfg.inputInterfaces) {
          lantian.firewall.chains.FILTER_INPUT.rules = [
            {
              priority = LT.firewallPriorities.service;
              text = lib.concatStringsSep "\n" (map (i: "iifname ${i} jump PUBLIC_INPUT") cfg.inputInterfaces);
            }
          ];
        })
        (lib.mkIf (cfg.enable && ifaceRefsOk cfg.forwardInterfaces) {
          lantian.firewall.chains.FILTER_FORWARD.rules = [
            {
              priority = LT.firewallPriorities.service;
              text = lib.concatStringsSep "\n" (
                map (i: "iifname ${i} jump PUBLIC_FORWARD") cfg.forwardInterfaces
              );
            }
          ];
        })
      ]
    )

    (
      let
        cfg = config.lantian.firewall.presets.block-cn-ports;
      in
      lib.mkIf cfg.enable {
        lantian.firewall.ipsets = {
          CN_FIREWALLED_PORTS = {
            type = "inet_service";
            flags = [
              "constant"
              "interval"
            ];
            # DN42 port range
            elements = [ "20000-23999" ];
          };
          CN_IPV4 = {
            type = "ipv4_addr";
            flags = [
              "constant"
              "interval"
            ];
            elements = LT.constants.china-mainland.IPv4;
          };
          CN_IPV6 = {
            type = "ipv6_addr";
            flags = [
              "constant"
              "interval"
            ];
            elements = LT.constants.china-mainland.IPv6;
          };
        };
        lantian.firewall.chains.PUBLIC_INPUT.rules = [
          {
            priority = LT.firewallPriorities.service;
            text = ''
              ip saddr @CN_IPV4 tcp dport @CN_FIREWALLED_PORTS reject with tcp reset
              ip saddr @CN_IPV4 udp dport @CN_FIREWALLED_PORTS reject with icmpx type port-unreachable
              ip6 saddr @CN_IPV6 tcp dport @CN_FIREWALLED_PORTS reject with tcp reset
              ip6 saddr @CN_IPV6 udp dport @CN_FIREWALLED_PORTS reject with icmpx type port-unreachable
            '';
          }
        ];
      }
    )

    (
      let
        cfg = config.lantian.firewall.presets.dn42;
      in
      lib.mkMerge [
        (lib.mkIf cfg.enable {
          lantian.firewall.ipsets = {
            DN42_FIREWALLED_PORTS = {
              type = "inet_service";
              flags = [
                "constant"
                "interval"
              ];
              # Avoid running DN42 on DN42
              elements = [ "20000-23999" ];
            };
            DN42_IPV4 = {
              type = "ipv4_addr";
              flags = [
                "constant"
                "interval"
              ];
              elements = LT.constants.dn42.IPv4;
            };
            DN42_IPV6 = {
              type = "ipv6_addr";
              flags = [
                "constant"
                "interval"
              ];
              elements = LT.constants.dn42.IPv6;
            };
            NEONETWORK_IPV4 = {
              type = "ipv4_addr";
              flags = [
                "constant"
                "interval"
              ];
              elements = LT.constants.neonetwork.IPv4;
            };
            NEONETWORK_IPV6 = {
              type = "ipv6_addr";
              flags = [
                "constant"
                "interval"
              ];
              elements = LT.constants.neonetwork.IPv6;
            };
            LOCAL_IPV4 = {
              type = "ipv4_addr";
              flags = [
                "constant"
                "interval"
              ];
              elements = [ "${LT.this.ltnet.IPv4Prefix}.0/24" ];
            };
            LOCAL_IPV6 = {
              type = "ipv6_addr";
              flags = [
                "constant"
                "interval"
              ];
              elements = [ "${LT.this.ltnet.IPv6Prefix}::/64" ];
            };
          };
          lantian.firewall.chains.FILTER_INPUT.rules = [
            {
              priority = LT.firewallPriorities.terminal;
              text = ''
                ip saddr @DN42_IPV4 jump DN42_INPUT
                ip6 saddr @DN42_IPV6 jump DN42_INPUT
                ip saddr @NEONETWORK_IPV4 jump DN42_INPUT
                ip6 saddr @NEONETWORK_IPV6 jump DN42_INPUT
              '';
            }
          ];
          lantian.firewall.chains.DN42_INPUT.rules = [
            {
              priority = LT.firewallPriorities.early;
              text = ''
                fib daddr type local tcp dport @DN42_FIREWALLED_PORTS reject with tcp reset
                fib daddr type local udp dport @DN42_FIREWALLED_PORTS reject with icmpx type port-unreachable
              '';
            }
            {
              priority = LT.firewallPriorities.terminal;
              text = "return";
            }
          ];
          lantian.firewall.chains.DN42_FORWARD.rules = [
            {
              priority = LT.firewallPriorities.early;
              text = lib.concatStringsSep "\n" (
                [
                  "fib daddr type local return"
                  "ip daddr @DN42_IPV4 return"
                  "ip6 daddr @DN42_IPV6 return"
                ]
                ++ lib.optional interfaceSetsEnabled "oifname @INTERFACE_DN42 return"
              );
            }
            {
              priority = LT.firewallPriorities.terminal;
              text = "reject with icmpx type admin-prohibited";
            }
          ];
        })
        (lib.mkIf (cfg.enable && interfaceSetsEnabled) {
          lantian.firewall.chains.FILTER_FORWARD.rules = [
            {
              priority = LT.firewallPriorities.terminal;
              text = "iifname @INTERFACE_DN42 jump DN42_FORWARD";
            }
          ];
        })
        (lib.mkIf (cfg.enable && interfaceSetsEnabled && LT.this.neonetwork.IPv4 != null) {
          lantian.firewall.chains.NAT_POSTROUTING.rules = [
            {
              priority = LT.firewallPriorities.early;
              text = ''
                ip saddr != @DN42_IPV4 ip daddr @NEONETWORK_IPV4 ip daddr != @LOCAL_IPV4 oifname != @INTERFACE_WAN oifname != @INTERFACE_OVERLAY snat to ${LT.this.neonetwork.IPv4}
                ip6 saddr != @DN42_IPV6 ip6 daddr @NEONETWORK_IPV6 ip6 daddr != @LOCAL_IPV6 oifname != @INTERFACE_WAN oifname != @INTERFACE_OVERLAY snat to ${LT.this.neonetwork.IPv6}
              '';
            }
          ];
        })
        (lib.mkIf (cfg.enable && interfaceSetsEnabled && LT.this.dn42.IPv4 != null) {
          lantian.firewall.chains.NAT_POSTROUTING.rules = [
            {
              priority = LT.firewallPriorities.preService;
              text = ''
                ip saddr != @DN42_IPV4 ip daddr @DN42_IPV4 ip daddr != @NEONETWORK_IPV4 ip daddr != @LOCAL_IPV4 oifname != @INTERFACE_WAN oifname != @INTERFACE_OVERLAY snat to ${LT.this.dn42.IPv4}
                ip6 saddr != @DN42_IPV6 ip6 daddr @DN42_IPV6 ip6 daddr != @NEONETWORK_IPV6 ip6 daddr != @LOCAL_IPV6 oifname != @INTERFACE_WAN oifname != @INTERFACE_OVERLAY snat to ${LT.this.dn42.IPv6}
              '';
            }
          ];
        })
      ]
    )

    (lib.mkIf config.lantian.firewall.presets.sidestore.enable {
      lantian.firewall.chains.NAT_PREROUTING.rules = [
        {
          priority = LT.firewallPriorities.preService;
          text = "ip daddr 10.7.0.1 ip daddr set ip saddr ip saddr set 10.7.0.1 notrack";
        }
      ];
    })

    (
      let
        cfg = config.lantian.firewall.presets.kms-redirect;
      in
      lib.mkMerge [
        (lib.mkIf (cfg.enable && ifaceRefsOk cfg.lanInterfaces) {
          lantian.firewall.chains.NAT_PREROUTING.dnat = [
            {
              priority = LT.firewallPriorities.service;
              matches = map (i: "tcp dport ${LT.portStr.KMS} iifname ${i}") cfg.lanInterfaces;
              ipv4 = "${cfg.targetIPv4}:${LT.portStr.KMS}";
              ipv6 = "[${cfg.targetIPv6}]:${LT.portStr.KMS}";
            }
          ];
        })
        (lib.mkIf cfg.enable {
          lantian.firewall.chains.NAT_OUTPUT.dnat = [
            {
              priority = LT.firewallPriorities.early;
              matches = [ "tcp dport ${LT.portStr.KMS}" ];
              ipv4 = "${cfg.targetIPv4}:${LT.portStr.KMS}";
              ipv6 = "[${cfg.targetIPv6}]:${LT.portStr.KMS}";
            }
          ];
        })
      ]
    )

    (lib.mkIf config.lantian.firewall.presets.ltnet-fallback-snat.enable {
      lantian.firewall.chains.NAT_POSTROUTING.rules = [
        {
          priority = LT.firewallPriorities.service;
          text = ''
            ip daddr 198.18.0.200-198.18.0.255 snat to ${LT.this.ltnet.IPv4}
            ip6 daddr fdbc:f9dc:67ad::200-fdbc:f9dc:67ad::255 snat to ${LT.this.ltnet.IPv6}
          '';
        }
      ];
    })

    (lib.mkIf config.lantian.firewall.presets.masquerade.enable {
      lantian.firewall.chains.NAT_POSTROUTING.rules = [
        {
          priority = LT.firewallPriorities.terminal;
          text = ''
            ip saddr @RESERVED_IPV4 ip daddr != @RESERVED_IPV4 masquerade
            ip6 saddr @RESERVED_IPV6 ip6 daddr != @RESERVED_IPV6 masquerade
          '';
        }
      ];
    })

    (
      let
        cfg = config.lantian.firewall.presets.dns-redirect;
        iifnames = lib.concatMapStrings (j: " iifname ${j}") cfg.lanInterfaces;
      in
      lib.mkIf (cfg.enable && cfg.netns != null) {
        lantian.firewall.chains.NAT_PREROUTING.dnat = [
          {
            priority = LT.firewallPriorities.service;
            matches = map (proto: "fib daddr type local ${proto} dport ${LT.portStr.DNS}${iifnames}") [
              "tcp"
              "udp"
            ];
            ipv4 = "${config.lantian.netns.${cfg.netns}.ipv4}:${LT.portStr.DNS}";
            ipv6 = "[${config.lantian.netns.${cfg.netns}.ipv6}]:${LT.portStr.DNS}";
          }
        ];
      }
    )

    (
      let
        cfg = config.lantian.firewall.presets.block-ipv6;
      in
      lib.mkIf cfg.enable {
        lantian.firewall.chains.FILTER_INPUT.rules = [
          {
            priority = LT.firewallPriorities.preService;
            text = lib.concatStringsSep "\n" (map (i: "iifname ${i} meta nfproto ipv6 drop") cfg.interfaces);
          }
        ];
        lantian.firewall.chains.FILTER_OUTPUT.rules = [
          {
            priority = LT.firewallPriorities.preService;
            text = lib.concatStringsSep "\n" (map (i: "oifname ${i} meta nfproto ipv6 drop") cfg.interfaces);
          }
        ];
      }
    )

    (
      let
        cfg = config.lantian.firewall.presets.vlan-isolate;
      in
      lib.mkIf cfg.enable {
        lantian.firewall.chains.FILTER_FORWARD.rules = [
          {
            priority = LT.firewallPriorities.terminal;
            text = lib.concatStringsSep "\n" (
              map (i: "iifname ${i} oifname ${i} jump VLAN_ISOLATE") cfg.interfaces
            );
          }
        ];
        lantian.firewall.chains.VLAN_ISOLATE.rules = [
          {
            priority = LT.firewallPriorities.early;
            text = ''
              tcp dport { ${lib.concatStringsSep ", " (map builtins.toString cfg.allowTcpPorts)} } accept
              udp dport { ${lib.concatStringsSep ", " (map builtins.toString cfg.allowUdpPorts)} } accept
            '';
          }
          {
            priority = LT.firewallPriorities.preService;
            text = lib.concatStringsSep "\n" (map (ip: "ip daddr ${ip} accept") cfg.allowDestIPs);
          }
          {
            priority = LT.firewallPriorities.service;
            text = lib.concatStringsSep "\n" (
              (map (i: "iifname ${i} accept") cfg.allowFromInterfaces)
              ++ (map (p: "iifname ${p.from} oifname ${p.to} accept") cfg.allowInterfacePairs)
            );
          }
          {
            priority = LT.firewallPriorities.terminal;
            text = "reject with icmpx type admin-prohibited";
          }
        ];
      }
    )

    (
      let
        cfg = config.lantian.firewall.presets.port-forward;

        # Each entry expands to family-major rules (all IPv4 first, then IPv6)
        # with one rule per destination match and protocol.
        renderForward =
          entry:
          let
            iifnames = lib.concatMapStrings (i: " iifname ${i}") entry.interfaces;
            dests4 =
              if entry.destination == "local" then
                [ "fib daddr type local" ]
              else if entry.destination == "public" then
                lib.optionals (LT.this.public.IPv4 != null) [ "ip daddr ${LT.this.public.IPv4}" ]
              else
                map (a: "ip daddr ${a}") entry.destinationIPv4;
            dests6 =
              if entry.destination == "local" then
                [ "fib daddr type local" ]
              else if entry.destination == "public" then
                lib.optionals (LT.this.public.IPv6 != null) [ "ip6 daddr ${LT.this.public.IPv6}" ]
              else
                map (a: "ip6 daddr ${a}") entry.destinationIPv6;
            target6 =
              if entry.targetIPv6 == null then
                null
              else if lib.hasPrefix "[" entry.targetIPv6 then
                entry.targetIPv6
              else
                "[${entry.targetIPv6}]";
            matches4 =
              if entry.ports == null then
                map (d: "${d}${iifnames}") dests4
              else
                lib.concatMap (p: map (d: "${d}${iifnames} ${p} dport ${entry.ports}") dests4) entry.protocols;
            matches6 =
              if entry.ports == null then
                map (d: "${d}${iifnames}") dests6
              else
                lib.concatMap (p: map (d: "${d}${iifnames} ${p} dport ${entry.ports}") dests6) entry.protocols;
          in
          (lib.optionals (entry.targetIPv4 != null && matches4 != [ ]) [
            {
              priority = LT.firewallPriorities.early;
              matches = matches4;
              ipv4 = entry.targetIPv4;
            }
          ])
          ++ (lib.optionals (entry.targetIPv6 != null && matches6 != [ ]) [
            {
              priority = LT.firewallPriorities.early;
              matches = matches6;
              ipv6 = target6;
            }
          ]);
      in
      lib.mkIf cfg.enable {
        lantian.firewall.chains.NAT_PREROUTING.dnat = lib.concatMap renderForward cfg.forwards;
        lantian.firewall.chains.NAT_PORT_FORWARD.rules = [ ];
        lantian.firewall.chains.NAT_PREROUTING.rules = [
          {
            priority = LT.firewallPriorities.terminal;
            text = lib.concatStringsSep "\n" (
              (map (i: "fib daddr type local iifname ${i} jump NAT_PORT_FORWARD") cfg.wanInterfaces)
              ++ (map (
                i: "fib daddr type local iifname ${i} ip daddr != @RESERVED_IPV4 jump NAT_PORT_FORWARD"
              ) cfg.hairpinInterfaces)
              ++ (map (
                i: "fib daddr type local iifname ${i} ip6 daddr != @RESERVED_IPV6 jump NAT_PORT_FORWARD"
              ) cfg.hairpinInterfaces)
            );
          }
        ];
        lantian.firewall.chains.NAT_POSTROUTING.rules = [
          {
            priority = LT.firewallPriorities.service;
            text = lib.concatStringsSep "\n" (
              map (i: "meta iifname ${i} oifname ${i} masquerade") cfg.hairpinMasqueradeInterfaces
            );
          }
        ];
      }
    )

    (
      let
        cfg = config.lantian.firewall.presets.masquerade-outbound;
      in
      lib.mkIf cfg.enable {
        lantian.firewall.chains.NAT_POSTROUTING.rules = [
          {
            priority = LT.firewallPriorities.early;
            text = "meta nfproto ipv4 ${
              lib.concatMapStrings (i: "oifname != ${i} ") cfg.excludeInterfaces
            }masquerade";
          }
        ];
      }
    )

    (
      let
        cfg = config.lantian.firewall.presets.block-outbound-src-ports;
      in
      lib.mkIf (cfg.enable && config.lantian.firewall.presets.public-firewall.enable) {
        lantian.firewall.chains.PUBLIC_OUTPUT.rules = [
          {
            priority = LT.firewallPriorities.early;
            text = ''
              tcp sport @PUBLIC_FIREWALLED_PORTS drop
              udp sport @PUBLIC_FIREWALLED_PORTS drop
            '';
          }
          {
            priority = LT.firewallPriorities.terminal;
            text = "return";
          }
        ];
        lantian.firewall.chains.FILTER_OUTPUT.rules = [
          {
            priority = LT.firewallPriorities.terminal;
            text = lib.concatStringsSep "\n" (
              map (i: "fib saddr type local oifname ${i} jump PUBLIC_OUTPUT") cfg.outputInterfaces
            );
          }
        ];
      }
    )
  ];
}
