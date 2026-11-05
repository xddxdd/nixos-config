{
  LT,
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
        priority = LT.firewallPriorities.terminal;
        text = ''iifname "eth1*" drop'';
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
