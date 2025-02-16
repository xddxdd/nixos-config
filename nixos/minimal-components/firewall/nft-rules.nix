{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  serverPortForwards =
    lib.optionalString (config.lantian.netns.coredns-authoritative.enable or false)
      ''
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

  interfaceSets = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: ''
      set INTERFACE_${k} {
        type ifname
        flags constant, interval
        elements = { ${builtins.concatStringsSep ", " (builtins.map (v: v + "*") v)} }
      }
    '') LT.constants.interfacePrefixes
  );

  tnl-buyvm =
    (lib.optionalString (LT.this.public.IPv4 != "") (
      lib.concatStrings (
        lib.mapAttrsToList (
          _n:
          { index, ... }:
          ''
            ip daddr ${LT.this.public.IPv4} tcp dport { ${
              builtins.toString (LT.port.WGLanTian.ForwardStart + (index - 1) * 10)
            }-${
              builtins.toString (LT.port.WGLanTian.ForwardStart + index * 10 - 1)
            } } dnat to 198.18.${builtins.toString index}.192
            ip daddr ${LT.this.public.IPv4} udp dport { ${
              builtins.toString (LT.port.WGLanTian.ForwardStart + (index - 1) * 10)
            }-${
              builtins.toString (LT.port.WGLanTian.ForwardStart + index * 10 - 1)
            } } dnat to 198.18.${builtins.toString index}.192
          ''
        ) LT.hosts
      )
    ))
    + (lib.optionalString (LT.this.public.IPv6 != "") (
      lib.concatStrings (
        lib.mapAttrsToList (
          _n:
          { index, ... }:
          ''
            ip6 daddr ${LT.this.public.IPv6} tcp dport { ${
              builtins.toString (LT.port.WGLanTian.ForwardStart + (index - 1) * 10)
            }-${
              builtins.toString (LT.port.WGLanTian.ForwardStart + index * 10 - 1)
            } } dnat to fdbc:f9dc:67ad:${builtins.toString index}::192
            ip6 daddr ${LT.this.public.IPv6} udp dport { ${
              builtins.toString (LT.port.WGLanTian.ForwardStart + (index - 1) * 10)
            }-${
              builtins.toString (LT.port.WGLanTian.ForwardStart + index * 10 - 1)
            } } dnat to fdbc:f9dc:67ad:${builtins.toString index}::192
          ''
        ) LT.hosts
      )
    ))
    + (lib.optionalString (LT.this.public.IPv6Subnet != "") (
      lib.concatStrings (
        lib.mapAttrsToList (_n: v: ''
          ip6 daddr ${LT.this.public.IPv6Subnet}${builtins.toString v.index} dnat to fdbc:f9dc:67ad:${builtins.toString v.index}::192
        '') LT.hosts
      )
    ));

  text =
    ''
      #${pkgs.nftables}/bin/nft -f
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
          iifname @INTERFACE_OVERLAY jump PUBLIC_INPUT
        }

        chain FILTER_FORWARD {
          type filter hook forward priority 5; policy accept;

          # DN42 firewall rules
          iifname @INTERFACE_DN42 jump DN42_FORWARD

          # Restrict Iodine to only allow WAN access
          iifname "dns*" oifname != @INTERFACE_WAN drop
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
    + (lib.optionalString (config.services ? proxmox-ve && config.services.proxmox-ve.enable) ''
      fib daddr type local tcp dport 443 redirect to :8006
    '')
    + (lib.optionalString (config.lantian ? nginx-proxy && config.lantian.nginx-proxy.enable) ''
      # nginx whois & gopher server
      fib daddr type local tcp dport ${LT.portStr.Whois} dnat ip to ${config.lantian.netns.nginx-proxy.ipv4}:${LT.portStr.Whois}
      fib daddr type local tcp dport ${LT.portStr.Gopher} dnat ip to ${config.lantian.netns.nginx-proxy.ipv4}:${LT.portStr.Gopher}
      fib daddr type local tcp dport ${LT.portStr.Whois} dnat ip6 to [${config.lantian.netns.nginx-proxy.ipv6}]:${LT.portStr.Whois}
      fib daddr type local tcp dport ${LT.portStr.Gopher} dnat ip6 to [${config.lantian.netns.nginx-proxy.ipv6}]:${LT.portStr.Gopher}
    '')
    + ''
        ${serverPortForwards}
        ${tnl-buyvm}

        # Redirect all KMS requests to internal server
        tcp dport ${LT.portStr.KMS} iifname @INTERFACE_LAN dnat ip to 198.19.0.252:${LT.portStr.KMS}
        tcp dport ${LT.portStr.KMS} iifname @INTERFACE_LAN dnat ip6 to [fdbc:f9dc:67ad:2547::1688]:${LT.portStr.KMS}
      }

      chain NAT_INPUT {
        type nat hook input priority 105; policy accept;
      }

      chain NAT_OUTPUT {
        type nat hook output priority -95; policy accept;

        # Redirect all KMS requests to internal server
        tcp dport ${LT.portStr.KMS} dnat ip to 198.19.0.252:${LT.portStr.KMS}
        tcp dport ${LT.portStr.KMS} dnat ip6 to [fdbc:f9dc:67ad:2547::1688]:${LT.portStr.KMS}
      }

      chain NAT_POSTROUTING {
        type nat hook postrouting priority 105; policy accept;

        # tnl-buyvm
    ''
    + (lib.optionalString (LT.this.neonetwork.IPv4 != "") ''
      # give LAN access to NeoNetwork
      ip saddr != @DN42_IPV4 ip daddr @NEONETWORK_IPV4 ip daddr != @LOCAL_IPV4 oifname != @INTERFACE_WAN oifname != @INTERFACE_OVERLAY snat to ${LT.this.neonetwork.IPv4}
      ip6 saddr != @DN42_IPV6 ip6 daddr @NEONETWORK_IPV6 ip6 daddr != @LOCAL_IPV6 oifname != @INTERFACE_WAN oifname != @INTERFACE_OVERLAY snat to ${LT.this.neonetwork.IPv6}
    '')
    + (lib.optionalString (LT.this.dn42.IPv4 != "") ''
      # give LAN access to DN42
      ip saddr != @DN42_IPV4 ip daddr @DN42_IPV4 ip daddr != @NEONETWORK_IPV4 ip daddr != @LOCAL_IPV4 oifname != @INTERFACE_WAN oifname != @INTERFACE_OVERLAY snat to ${LT.this.dn42.IPv4}
      ip6 saddr != @DN42_IPV6 ip6 daddr @DN42_IPV6 ip6 daddr != @NEONETWORK_IPV6 ip6 daddr != @LOCAL_IPV6 oifname != @INTERFACE_WAN oifname != @INTERFACE_OVERLAY snat to ${LT.this.dn42.IPv6}
    '')
    + ''
        # 198.18.0.200-255, fdbc:f9dc:67ad::200-255 is for devices without BGP sessions
        ip daddr 198.18.0.200-198.18.0.255 snat to ${LT.this.ltnet.IPv4}
        ip6 daddr fdbc:f9dc:67ad::200-fdbc:f9dc:67ad::255 snat to ${LT.this.ltnet.IPv6}

        ip saddr @RESERVED_IPV4 ip daddr != @RESERVED_IPV4 masquerade
        ip6 saddr @RESERVED_IPV6 ip6 daddr != @RESERVED_IPV6 masquerade
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
      ${ipv4Set "LOCAL_IPV4" [ "${LT.this.ltnet.IPv4Prefix}.0/24" ]}
      ${ipv6Set "LOCAL_IPV6" [ "${LT.this.ltnet.IPv6Prefix}::/64" ]}

      set PUBLIC_FIREWALLED_PORTS {
        type inet_service
        flags constant
        elements = {
          # Samba
          137, 138, 139, 445,
          # NFS
          111, 2049, 4000, 4001, 4002, 20048,
          # CUPS
          631,
    ''
    + (lib.optionalString (!config.services.avahi.enable) ''
      # mDNS
      5353,
    '')
    + ''
            # Rsync
            873
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
