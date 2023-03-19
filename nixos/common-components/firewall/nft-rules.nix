{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  serverPortForwards = lib.optionalString (config.lantian.netns.coredns-authoritative.enable or false) ''
    # network namespace coredns
    fib daddr type local tcp dport ${LT.portStr.DNS} dnat ip to ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.DNS}
    fib daddr type local udp dport ${LT.portStr.DNS} dnat ip to ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.DNS}
    fib daddr type local tcp dport ${LT.portStr.DNS} dnat ip6 to [${config.lantian.netns.coredns-authoritative.ipv6}]:${LT.portStr.DNS}
    fib daddr type local udp dport ${LT.portStr.DNS} dnat ip6 to [${config.lantian.netns.coredns-authoritative.ipv6}]:${LT.portStr.DNS}
  '';

  ipv4Set = name: value: ''
    set ${name} {
      type ipv4_addr
      flags constant, interval
      elements = { ${builtins.concatStringsSep ", " value} }
    }
  '';

  ipv6Set = name: value: ''
    set ${name} {
      type ipv6_addr
      flags constant, interval
      elements = { ${builtins.concatStringsSep ", " value} }
    }
  '';

  interfaceSets = builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''
      set INTERFACE_${k} {
        type ifname
        flags constant, interval
        elements = { ${builtins.concatStringsSep ", " (builtins.map (v: v + "*") v)} }
      }
    '')
    LT.constants.interfacePrefixes);

  wg-lantian =
    (
      lib.optionalString (LT.this.public.IPv4 != "")
      (lib.concatStrings
        (lib.mapAttrsToList
          (n: {index, ...}: ''
            ip daddr ${LT.this.public.IPv4} tcp dport { ${builtins.toString (LT.port.WGLanTian.ForwardStart + (index - 1) * 10)}-${builtins.toString (LT.port.WGLanTian.ForwardStart + index * 10 - 1)} } dnat to 192.0.2.${builtins.toString index}
            ip daddr ${LT.this.public.IPv4} udp dport { ${builtins.toString (LT.port.WGLanTian.ForwardStart + (index - 1) * 10)}-${builtins.toString (LT.port.WGLanTian.ForwardStart + index * 10 - 1)} } dnat to 192.0.2.${builtins.toString index}
          '')
          LT.hosts))
    )
    + (
      lib.optionalString (LT.this.public.IPv6Subnet != "")
      (lib.concatStrings
        (lib.mapAttrsToList
          (n: v: ''
            ip6 daddr ${LT.this.public.IPv6Subnet}${builtins.toString v.index} dnat to fc00::${builtins.toString v.index}
          '')
          LT.hosts))
    );

  text =
    ''
      #${pkgs.nftables-fullcone}/bin/nft -f
      table inet lantian
      delete table inet lantian

      table inet lantian {
        chain FILTER_INPUT {
          type filter hook input priority 5; policy accept;

          # Drop timestamp ICMP pkts
          meta l4proto icmp icmp type timestamp-reply drop
          meta l4proto icmp icmp type timestamp-request drop

          # Block Avahi Multicast DNS on ZeroTier
          iifname "zt*" udp sport 5353 reject
          iifname "zt*" udp dport 5353 reject

          # Block certain ports from public internet
          iifname @INTERFACE_WAN jump PUBLIC_INPUT
        }

        chain FILTER_FORWARD {
          type filter hook forward priority 5; policy accept;

          # DN42 firewall rules
          iifname @INTERFACE_DN42 jump DN42_FORWARD
        }

        chain FILTER_OUTPUT {
          type filter hook output priority 5; policy accept;

          # Block Avahi Multicast DNS on ZeroTier
          oifname "zt*" udp sport 5353 reject
          oifname "zt*" udp dport 5353 reject
        }

        chain NAT_PREROUTING {
          type nat hook prerouting priority -95; policy accept;
    ''
    + (lib.optionalString config.lantian.nginx-proxy.enable ''
      # nginx whois & gopher server
      fib daddr type local tcp dport ${LT.portStr.Whois} dnat ip to ${config.lantian.netns.nginx-proxy.ipv4}:${LT.portStr.Whois}
      fib daddr type local tcp dport ${LT.portStr.Gopher} dnat ip to ${config.lantian.netns.nginx-proxy.ipv4}:${LT.portStr.Gopher}
      fib daddr type local tcp dport ${LT.portStr.Whois} dnat ip6 to [${config.lantian.netns.nginx-proxy.ipv6}]:${LT.portStr.Whois}
      fib daddr type local tcp dport ${LT.portStr.Gopher} dnat ip6 to [${config.lantian.netns.nginx-proxy.ipv6}]:${LT.portStr.Gopher}
    '')
    + ''
        ${serverPortForwards}
        ${wg-lantian}
      }

      chain NAT_INPUT {
        type nat hook input priority 105; policy accept;
      }

      chain NAT_OUTPUT {
        type nat hook output priority -95; policy accept;
      }

      chain NAT_POSTROUTING {
        type nat hook postrouting priority 105; policy accept;

        # wg-lantian
    ''
    + (
      lib.optionalString (LT.this.public.IPv6Subnet != "")
      (builtins.concatStringsSep "\n"
        (lib.mapAttrsToList (
          n: v: "ip6 saddr fc00::${builtins.toString v.index} snat to ${LT.this.public.IPv6Subnet}${builtins.toString v.index}"
        ) (lib.filterAttrs (n: v: !(builtins.elem LT.tags.server v.tags)) LT.hosts)))
    )
    + ''
          # give LAN access to DN42
          ip saddr != @DN42_IPV4 ip daddr @NEONETWORK_IPV4 snat to ${LT.this.neonetwork.IPv4}
          ip saddr != @DN42_IPV4 ip daddr @DN42_IPV4 ip daddr != @NEONETWORK_IPV4 snat to ${LT.this.dn42.IPv4}
          ip6 saddr != @DN42_IPV6 ip6 daddr @NEONETWORK_IPV6 snat to ${LT.this.neonetwork.IPv6}
          ip6 saddr != @DN42_IPV6 ip6 daddr @DN42_IPV6 ip6 daddr != @NEONETWORK_IPV6 snat to ${LT.this.dn42.IPv6}

          ip saddr @RESERVED_IPV4 oifname @INTERFACE_WAN masquerade
          ip6 saddr @RESERVED_IPV6 oifname @INTERFACE_WAN masquerade
        }

        # Interface sets
        ${interfaceSets}

        # IP Sets
        ${ipv4Set "RESERVED_IPV4" LT.constants.reserved.IPv4}
        ${ipv6Set "RESERVED_IPV6" LT.constants.reserved.IPv6}
        ${ipv4Set "DN42_IPV4" LT.constants.dn42.IPv4}
        ${ipv6Set "DN42_IPV6" LT.constants.dn42.IPv6}
        ${ipv4Set "NEONETWORK_IPV4" LT.constants.neonetwork.IPv4}
        ${ipv6Set "NEONETWORK_IPV6" LT.constants.neonetwork.IPv6}

        set PUBLIC_FIREWALLED_PORTS {
          type inet_service
          flags constant
          elements = {
            # Samba
            137, 138, 139, 445,
            # CUPS
            631,
            # Rsync,
            873,
            # mDNS
            5353
          }
        }

        # Helper chains
        chain PUBLIC_INPUT {
          # Block ports
          tcp dport @PUBLIC_FIREWALLED_PORTS reject with tcp reset
          udp dport @PUBLIC_FIREWALLED_PORTS reject with icmpx type port-unreachable
          return
        }

        chain DN42_FORWARD {
          fib daddr type local return
          ip daddr @DN42_IPV4 return
          ip6 daddr @DN42_IPV6 return
          oifname @INTERFACE_DN42 return
          reject with icmpx type admin-prohibited
        }
      }
    '';
in
  pkgs.writeText "nft.conf" text
