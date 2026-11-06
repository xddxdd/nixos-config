{
  LT,
  lib,
  ...
}:
{
  lantian.firewall.presets = {
    # Generic presets that don't apply to this router
    interface-sets.enable = false;
    dn42.enable = false;
    block-cn-ports.enable = false;
    ltnet-fallback-snat.enable = false;
    masquerade.enable = false;

    public-firewall = {
      inputInterfaces = [ ''"eth1*"'' ];
      forwardInterfaces = [ ];
      # WAN-side needs: DHCPv4 replies from the ISP (dport 68) fall outside
      # the ephemeral range.
      allowedPorts = [ LT.port.DHCP.Client ];
    };

    kms-redirect.lanInterfaces = [ ''"eth0*"'' ];

    # Block IPv6 from Quantum Fiber
    block-ipv6 = {
      enable = true;
      interfaces = [ ''"eth1*"'' ];
    };

    dns-redirect = {
      enable = true;
      netns = "coredns-client";
      lanInterfaces = [ ''"eth0*"'' ];
    };

    vlan-isolate = {
      enable = true;
      interfaces = [ ''"eth0*"'' ];
      allowDestIPs = [ "192.168.0.4" ];
      allowFromInterfaces = [ ''"eth0"'' ];
      allowInterfacePairs = [
        {
          from = ''"eth0.1"'';
          to = ''"eth0.5"'';
        }
      ];
    };

    port-forward = {
      enable = true;
      wanInterfaces = [
        ''"eth1*"''
        ''"henet"''
      ];
      hairpinInterfaces = [ ''"eth0*"'' ];
      hairpinMasqueradeInterfaces = [ ''"eth0"'' ];
    };

    masquerade-outbound = {
      enable = true;
      excludeInterfaces = [
        ''"eth0*"''
        ''"lo"''
      ];
    };

  };

  # IPv6 addresses of hosts on the same home-lan interconnect; hosts
  # without an interconnect IPv6 (e.g. lt-dell-wyse) contribute nothing.
  lantian.firewall.ipsets.LAN_HOSTS_IPV6 = {
    type = "ipv6_addr";
    flags = [
      "constant"
      "interval"
    ];
    elements = lib.map (h: h.interconnect.IPv6) (
      lib.filter (h: h.interconnect.name == LT.this.interconnect.name && h.interconnect.IPv6 != null) (
        builtins.attrValues LT.hosts
      )
    );
  };

  lantian.firewall.chains = {
    NAT_PORT_FORWARD.dnat = [
      {
        priority = LT.firewallPriorities.early;
        matches = [
          "meta nfproto ipv4 tcp dport 31080-31089"
          "meta nfproto ipv4 udp dport 31080-31089"
        ];
        ipv4 = "192.168.0.2";
      }
      {
        priority = LT.firewallPriorities.early;
        matches = [ "meta nfproto ipv4 udp dport 22547" ];
        ipv4 = "192.168.0.2";
      }
      {
        priority = LT.firewallPriorities.early;
        matches = [ "meta nfproto ipv6 udp dport 22547" ];
        ipv6 = "[2001:470:e997::2]";
      }
    ];
    FILTER_FORWARD.rules = [
      {
        # Access to the router itself is input-chain traffic and never hits
        # the forward hook; accept it here explicitly so the drops below can
        # never catch it.
        priority = LT.firewallPriorities.preService;
        text = "fib daddr type local accept";
      }
      {
        # Whitelist config-managed hosts with IPv6 addresses in the home /48,
        # scoped to the public ingress interface so VLAN isolation rules
        # below keep applying to LAN-internal traffic.
        priority = LT.firewallPriorities.preService;
        text = ''iifname "henet" ip6 daddr @LAN_HOSTS_IPV6 accept'';
      }
      {
        priority = LT.firewallPriorities.terminal;
        text = ''iifname "eth1*" drop'';
      }
      {
        # Default-deny IPv6 from the internet (henet tunnel) to LAN hosts.
        # DNAT'd port-forwards are accepted earlier by the generic
        # "ct status dnat" rule, so only direct global-address access is
        # blocked here.
        priority = LT.firewallPriorities.terminal;
        text = ''iifname "henet" meta nfproto ipv6 drop'';
      }
    ];
    NAT_POSTROUTING.rules = [
      # Avoid using ZeroTier as return path
      {
        priority = LT.firewallPriorities.preService;
        text = ''meta nfproto ipv4 iifname "ns-*" oifname "eth0*" masquerade'';
      }
      {
        priority = LT.firewallPriorities.terminal;
        text = ''oifname "henet" ip6 saddr fc00:192:168::/48 snat ip6 prefix to 2001:470:e997::/48'';
      }
    ];
  };

  # Preserve the old block-outbound-src-ports behavior for this host: drop
  # locally-generated SSDP/mDNS (sport 5353) leaving via the WAN interface.
  lantian.firewall.chains.PUBLIC_OUTPUT.rules = [
    {
      priority = LT.firewallPriorities.early;
      text = ''
        tcp sport ${LT.portStr.mDNS} drop
        udp sport ${LT.portStr.mDNS} drop
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
      text = ''fib saddr type local oifname "eth1*" jump PUBLIC_OUTPUT'';
    }
  ];
}
