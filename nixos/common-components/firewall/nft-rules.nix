{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../../helpers args;
in
pkgs.writeText "nft.conf" ''
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
    }

    chain FILTER_FORWARD {
      type filter hook forward priority 5; policy accept;

      # DN42 firewall rules
      ${lib.concatMapStringsSep "\n" (p: ''iifname "dn42*" oifname "${p}*" reject'') LT.constants.wanInterfacePrefixes}

      # Block non-DN42 traffic in DN42
      iifname "dn42*" jump DN42_INPUT
      oifname "dn42*" jump DN42_OUTPUT
    }

    chain FILTER_OUTPUT {
      type filter hook output priority 5; policy accept;
      oifname "dn42*" jump DN42_OUTPUT
    }

    chain NAT_PREROUTING {
      type nat hook prerouting priority -95; policy accept;

      # nginx whois & gopher server
      fib daddr type local tcp dport ${LT.portStr.Whois} dnat ip to ${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.nginx-proxy}:${LT.portStr.Whois}
      fib daddr type local tcp dport ${LT.portStr.Gopher} dnat ip to ${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.nginx-proxy}:${LT.portStr.Gopher}
      fib daddr type local tcp dport ${LT.portStr.Whois} dnat ip6 to [${LT.this.ltnet.IPv6Prefix}::${LT.containerIP.nginx-proxy}]:${LT.portStr.Whois}
      fib daddr type local tcp dport ${LT.portStr.Gopher} dnat ip6 to [${LT.this.ltnet.IPv6Prefix}::${LT.containerIP.nginx-proxy}]:${LT.portStr.Gopher}

      ${lib.optionalString (LT.this.role == LT.roles.server) ''
        # network namespace coredns
        fib daddr type local tcp dport ${LT.portStr.DNS} dnat ip to ${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.coredns-authoritative}:${LT.portStr.DNS}
        fib daddr type local udp dport ${LT.portStr.DNS} dnat ip to ${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.coredns-authoritative}:${LT.portStr.DNS}
        fib daddr type local tcp dport ${LT.portStr.DNS} dnat ip6 to [${LT.this.ltnet.IPv6Prefix}::${LT.containerIP.coredns-authoritative}]:${LT.portStr.DNS}
        fib daddr type local udp dport ${LT.portStr.DNS} dnat ip6 to [${LT.this.ltnet.IPv6Prefix}::${LT.containerIP.coredns-authoritative}]:${LT.portStr.DNS}

        # network namespace yggdrasil-alfis
        fib daddr type local tcp dport ${LT.portStr.YggdrasilAlfis} dnat ip to ${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.yggdrasil-alfis}:${LT.portStr.YggdrasilAlfis}
        fib daddr type local tcp dport ${LT.portStr.YggdrasilAlfis} dnat ip6 to [${LT.this.ltnet.IPv6Prefix}::${LT.containerIP.yggdrasil-alfis}]:${LT.portStr.YggdrasilAlfis}
      ''}

      # wg-lantian
      ${lib.optionalString (LT.this.public.IPv4 != "") ''
        ip daddr ${LT.this.public.IPv4} tcp dport { 51820, 51821 } dnat to 192.0.2.100
        ip daddr ${LT.this.public.IPv4} udp dport { 51820, 51821 } dnat to 192.0.2.100
        ip daddr ${LT.this.public.IPv4} tcp dport { 57912 } dnat to 192.0.2.101
        ip daddr ${LT.this.public.IPv4} udp dport { 57912 } dnat to 192.0.2.101
      ''}
      ${lib.optionalString (LT.this.public.IPv6Subnet != "")
        (builtins.concatStringsSep "\n"
          (lib.mapAttrsToList (n: v:
            "ip6 daddr ${LT.this.public.IPv6Subnet}${builtins.toString v.index} dnat to fc00::${builtins.toString v.index}"
          ) (lib.filterAttrs (n: v: v.role != LT.roles.server) LT.hosts)))}
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
          ) (lib.filterAttrs (n: v: v.role != LT.roles.server) LT.hosts)))}

      ${lib.optionalString (LT.this.role == LT.roles.server) ''
        # give nixos containers access to DN42
        ip saddr 172.18.0.0/16 oifname "dn42-*" snat to ${LT.this.dn42.IPv4}
        ip saddr 172.18.0.0/16 oifname "neo-*" snat to ${LT.this.neonetwork.IPv4}
      ''}

      ${lib.concatMapStringsSep "\n" (p: ''oifname "${p}*" fullcone'') (LT.constants.wanInterfacePrefixes ++ [ "virbr" ])}
    }

    # Helper chains
    chain DN42_INPUT {
      ${lib.concatMapStringsSep "\n" (p: "ip saddr ${p} return") LT.constants.dn42.IPv4}
      ${lib.concatMapStringsSep "\n" (p: "ip6 saddr ${p} return") LT.constants.dn42.IPv6}
      reject with icmpx type admin-prohibited
    }

    chain DN42_OUTPUT {
      ${lib.concatMapStringsSep "\n" (p: "ip daddr ${p} return") LT.constants.dn42.IPv4}
      ${lib.concatMapStringsSep "\n" (p: "ip6 daddr ${p} return") LT.constants.dn42.IPv6}
      reject with icmpx type admin-prohibited
    }
  }
''
