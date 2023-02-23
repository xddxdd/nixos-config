{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  serverPortForwards = lib.optionalString (builtins.elem LT.tags.server LT.this.tags) ''
    # network namespace coredns
    fib daddr type local tcp dport ${LT.portStr.DNS} dnat ip to ${LT.this.ltnet.IPv4Prefix}.${LT.constants.containerIP.coredns-authoritative}:${LT.portStr.DNS}
    fib daddr type local udp dport ${LT.portStr.DNS} dnat ip to ${LT.this.ltnet.IPv4Prefix}.${LT.constants.containerIP.coredns-authoritative}:${LT.portStr.DNS}
    fib daddr type local tcp dport ${LT.portStr.DNS} dnat ip6 to [${LT.this.ltnet.IPv6Prefix}::${LT.constants.containerIP.coredns-authoritative}]:${LT.portStr.DNS}
    fib daddr type local udp dport ${LT.portStr.DNS} dnat ip6 to [${LT.this.ltnet.IPv6Prefix}::${LT.constants.containerIP.coredns-authoritative}]:${LT.portStr.DNS}

    # network namespace yggdrasil-alfis
    fib daddr type local tcp dport ${LT.portStr.YggdrasilAlfis} dnat ip to ${LT.this.ltnet.IPv4Prefix}.${LT.constants.containerIP.yggdrasil-alfis}:${LT.portStr.YggdrasilAlfis}
    fib daddr type local tcp dport ${LT.portStr.YggdrasilAlfis} dnat ip6 to [${LT.this.ltnet.IPv6Prefix}::${LT.constants.containerIP.yggdrasil-alfis}]:${LT.portStr.YggdrasilAlfis}
  '';

  wg-lantian = (lib.optionalString (LT.this.public.IPv4 != "")
    (lib.concatStrings
      (lib.mapAttrsToList
        (n: { index, ... }: ''
          ip daddr ${LT.this.public.IPv4} tcp dport { ${builtins.toString (LT.port.WGLanTian.ForwardStart + (index - 1) * 10)}-${builtins.toString (LT.port.WGLanTian.ForwardStart + index * 10 - 1)} } dnat to 192.0.2.${builtins.toString index}
          ip daddr ${LT.this.public.IPv4} udp dport { ${builtins.toString (LT.port.WGLanTian.ForwardStart + (index - 1) * 10)}-${builtins.toString (LT.port.WGLanTian.ForwardStart + index * 10 - 1)} } dnat to 192.0.2.${builtins.toString index}
        '')
        LT.hosts))
  )
  + (lib.optionalString (LT.this.public.IPv6Subnet != "")
    (lib.concatStrings
      (lib.mapAttrsToList
        (n: v: ''
          ip6 daddr ${LT.this.public.IPv6Subnet}${builtins.toString v.index} dnat to fc00::${builtins.toString v.index}
        '')
        LT.hosts))
  );

  text = ''
    #${pkgs.nftables-fullcone}/bin/nft -f
    table inet lantian
    delete table inet lantian

    table inet lantian {
      chain FILTER_INPUT {
        type filter hook input priority 5; policy accept;

        # Drop timestamp ICMP pkts
        meta l4proto icmp icmp type timestamp-reply drop
        meta l4proto icmp icmp type timestamp-request drop

        # Block non-DN42 traffic in DN42
        iifname "dn42*" jump DN42_INPUT
        iifname "zt*" jump DN42_INPUT

        # Block Avahi Multicast DNS on ZeroTier
        iifname "zt*" udp sport 5353 reject
        iifname "zt*" udp dport 5353 reject

        # Block certain ports from public internet
        jump PUBLIC_INPUT
      }

      chain FILTER_FORWARD {
        type filter hook forward priority 5; policy accept;

        # DN42 firewall rules
        ${lib.concatMapStringsSep "\n" (p: ''iifname "dn42*" oifname "${p}*" reject'') LT.constants.wanInterfacePrefixes}

        # Block non-DN42 traffic in DN42
        iifname "dn42*" jump DN42_INPUT
        iifname "zt*" jump DN42_INPUT
        oifname "dn42*" jump DN42_OUTPUT
        oifname "zt*" jump DN42_OUTPUT
      }

      chain FILTER_OUTPUT {
        type filter hook output priority 5; policy accept;
        oifname "dn42*" jump DN42_OUTPUT
        oifname "zt*" jump DN42_OUTPUT

        # Block Avahi Multicast DNS on ZeroTier
        oifname "zt*" udp sport 5353 reject
        oifname "zt*" udp dport 5353 reject
      }

      chain NAT_PREROUTING {
        type nat hook prerouting priority -95; policy accept;

        ${lib.optionalString config.lantian.nginx-proxy.enable ''
          # nginx whois & gopher server
          fib daddr type local tcp dport ${LT.portStr.Whois} dnat ip to ${LT.this.ltnet.IPv4Prefix}.${LT.constants.containerIP.nginx-proxy}:${LT.portStr.Whois}
          fib daddr type local tcp dport ${LT.portStr.Gopher} dnat ip to ${LT.this.ltnet.IPv4Prefix}.${LT.constants.containerIP.nginx-proxy}:${LT.portStr.Gopher}
          fib daddr type local tcp dport ${LT.portStr.Whois} dnat ip6 to [${LT.this.ltnet.IPv6Prefix}::${LT.constants.containerIP.nginx-proxy}]:${LT.portStr.Whois}
          fib daddr type local tcp dport ${LT.portStr.Gopher} dnat ip6 to [${LT.this.ltnet.IPv6Prefix}::${LT.constants.containerIP.nginx-proxy}]:${LT.portStr.Gopher}
        ''}

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
        ${lib.optionalString (LT.this.public.IPv6Subnet != "")
          (builtins.concatStringsSep "\n"
            (lib.mapAttrsToList (n: v:
              "ip6 saddr fc00::${builtins.toString v.index} snat to ${LT.this.public.IPv6Subnet}${builtins.toString v.index}"
            ) (lib.filterAttrs (n: v: !(builtins.elem LT.tags.server v.tags)) LT.hosts)))}

        ${lib.optionalString (builtins.elem LT.tags.server LT.this.tags) ''
          # give nixos containers access to DN42
          ip saddr 172.18.0.0/16 oifname "dn42-*" snat to ${LT.this.dn42.IPv4}
          ip saddr 172.18.0.0/16 oifname "neo-*" snat to ${LT.this.neonetwork.IPv4}
        ''}

        ${lib.concatMapStringsSep "\n" (p: ''
          ip saddr @RESERVED_IPV4 oifname "${p}*" fullcone
          ip6 saddr @RESERVED_IPV6 oifname "${p}*" fullcone
        '') LT.constants.wanInterfacePrefixes}
      }

      # Sets
      set RESERVED_IPV4 {
        type ipv4_addr
        flags constant, interval
        elements = { ${builtins.concatStringsSep ", " LT.constants.reserved.IPv4} }
      }

      set RESERVED_IPV6 {
        type ipv6_addr
        flags constant, interval
        elements = { ${builtins.concatStringsSep ", " LT.constants.reserved.IPv6} }
      }

      set DN42_IPV4 {
        type ipv4_addr
        flags constant, interval
        elements = { ${builtins.concatStringsSep ", " LT.constants.dn42.IPv4} }
      }

      set DN42_IPV6 {
        type ipv6_addr
        flags constant, interval
        elements = { ${builtins.concatStringsSep ", " LT.constants.dn42.IPv6} }
      }

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
        # Allow private ranges
        iifname "lo" return
        ip saddr @RESERVED_IPV4 return
        ip6 saddr @RESERVED_IPV6 return

        # Block ports
        # Samba
        tcp dport @PUBLIC_FIREWALLED_PORTS reject with tcp reset
        udp dport @PUBLIC_FIREWALLED_PORTS reject with icmpx type port-unreachable

        return
      }

      chain DN42_INPUT {
        iifname "zthnhe4bol" return
        ip saddr @DN42_IPV4 return
        ip6 saddr @DN42_IPV6 return
        reject with icmpx type admin-prohibited
      }

      chain DN42_OUTPUT {
        oifname "zthnhe4bol" return
        ip daddr @DN42_IPV4 return
        ip6 daddr @DN42_IPV6 return
        reject with icmpx type admin-prohibited
      }
    }
  '';
in
pkgs.writeText "nft.conf" text
