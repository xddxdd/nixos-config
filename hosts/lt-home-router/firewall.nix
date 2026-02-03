{
  LT,
  lib,
  config,
  ...
}:
let
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
in
{
  networking.nftables.tables.lantian.content = lib.mkForce ''
    chain FILTER_INPUT {
      type filter hook input priority 5; policy accept;

      # Drop timestamp ICMP pkts
      meta l4proto icmp icmp type timestamp-reply drop
      meta l4proto icmp icmp type timestamp-request drop

      # Block Avahi Multicast DNS on ZeroTier
      iifname "zt*" udp sport 5353 reject
      iifname "zt*" udp dport 5353 reject
    }

    chain FILTER_FORWARD {
      type filter hook forward priority 5; policy accept;

      # Clamp TCP MSS
      tcp flags syn tcp option maxseg size set rt mtu

      # Allow existing connections
      ct state { established, related } accept

      # Homelab VLAN isolation rules
      iifname "eth0*" jump VLAN_ISOLATE
    }

    chain VLAN_ISOLATE {
      # Allow user VLAN to access anything
      iifname "eth0" accept
      # Allow homelab VLAN to access IoT VLAN
      iifname "eth0.1" oifname "eth0.5" accept
      # Reject everything else
      reject with icmpx type admin-prohibited
    }

    chain FILTER_OUTPUT {
      type filter hook output priority 5; policy accept;

      # Block Avahi Multicast DNS on ZeroTier
      oifname "zt*" udp sport 5353 reject
      oifname "zt*" udp dport 5353 reject
    }

    chain NAT_PREROUTING {
      type nat hook prerouting priority -95; policy accept;

      # Redirect all KMS requests to internal server
      tcp dport ${LT.portStr.KMS} iifname "eth0*" dnat ip to 198.19.0.252:${LT.portStr.KMS}
      tcp dport ${LT.portStr.KMS} iifname "eth0*" dnat ip6 to [fdbc:f9dc:67ad:2547::1688]:${LT.portStr.KMS}

      # Redirect DNS requests to CoreDNS
      fib daddr type local tcp dport ${LT.portStr.DNS} iifname "eth0*" dnat ip to ${config.lantian.netns.coredns-client.ipv4}:${LT.portStr.DNS}
      fib daddr type local tcp dport ${LT.portStr.DNS} iifname "eth0*" dnat ip6 to [${config.lantian.netns.coredns-client.ipv6}]:${LT.portStr.DNS}
      fib daddr type local udp dport ${LT.portStr.DNS} iifname "eth0*" dnat ip to ${config.lantian.netns.coredns-client.ipv4}:${LT.portStr.DNS}
      fib daddr type local udp dport ${LT.portStr.DNS} iifname "eth0*" dnat ip6 to [${config.lantian.netns.coredns-client.ipv6}]:${LT.portStr.DNS}

      # Redirect to lt-home-vm
      fib daddr type local tcp dport 31010-31019 iifname "eth1" dnat ip to 192.168.1.10
      fib daddr type local udp dport 31010-31019 iifname "eth1" dnat ip to 192.168.1.10
      fib daddr type local tcp dport { 80, 443, 2222 } iifname "eth1" dnat ip to 192.168.1.10
      fib daddr type local udp dport 22547 iifname "eth1" dnat ip to 192.168.1.10

      # Redirect to lt-home-builder
      fib daddr type local tcp dport 2223 iifname "eth1" dnat ip to 192.168.1.12:2222
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

      oifname != "eth0*" masquerade
    }

    # IP Sets
    ${ipv4Set "RESERVED_IPV4" LT.constants.reserved.IPv4}
    ${ipv6Set "RESERVED_IPV6" LT.constants.reserved.IPv6}
  '';
}
