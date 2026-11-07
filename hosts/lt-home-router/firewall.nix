{
  LT,
  lib,
  ...
}:
{
  lantian.firewall.presets = {
    # Generic presets that don't apply to this router
    dn42.enable = false;
    ltnet-fallback-snat.enable = false;
    masquerade.enable = false;

    kms-redirect.lanInterfaces = [
      ''"eth0*"''
      ''"zt*"''
    ];

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

    masquerade-outbound = {
      enable = true;
      excludeInterfaces = [
        ''"eth0*"''
        ''"lo"''
      ];
    };

  };

  lantian.firewall.zones = {
    # eth0* is the LAN side of this router, even though it matches the WAN
    # eth* prefix; eth1* is the actual WAN uplink.
    LAN.interfaces = [ "eth0" ];
    WAN = {
      interfaces = lib.mkForce [ "eth1" ];
      # Port forwards from the public IP to the homelab host.
      tcpPorts."31080-31089" = {
        type = "forward";
        ipv4 = "192.168.0.2";
      };
      udpPorts."22547" = {
        type = "forward";
        ipv4 = "192.168.0.2";
      };
    };
    # henet is the IPv6 tunnel; its input was never filtered by the old
    # WAN zone, so keep it accept-all and only forward the explicit port
    # forward.
    HENET = {
      priority = 90;
      interfaces = [ "henet" ];
      inputPolicy = "accept";
      udpPorts."22547" = {
        type = "forward";
        ipv6 = "2001:470:e997::2";
      };
    };
    DN42.enable = false;
    WAN_CN_BLOCKED.enable = false;
  };

  # Hairpin NAT: LAN clients reaching the router's public IP hit the same
  # forwards as WAN clients.
  lantian.firewall.zones.LAN = {
    tcpPorts."31080-31089" = {
      type = "forward";
      ipv4 = "192.168.0.2";
    };
    udpPorts."22547" = {
      type = "forward";
      ipv4 = "192.168.0.2";
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
    FILTER_FORWARD.rules = [
      {
        # Access to the router itself is input-chain traffic and never hits
        # the forward hook; accept it here explicitly so the zone forward
        # policies can never catch it.
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
    ];
    NAT_POSTROUTING.rules = [
      # Avoid using ZeroTier as return path
      {
        priority = LT.firewallPriorities.preService;
        text = ''meta nfproto ipv4 iifname "ns-*" oifname "eth0*" masquerade'';
      }
      # Hairpin NAT for LAN clients reaching the router's public IP.
      {
        priority = LT.firewallPriorities.service;
        text = ''meta iifname "eth0" oifname "eth0" masquerade'';
      }
      {
        priority = LT.firewallPriorities.terminal;
        text = ''oifname "henet" ip6 saddr fc00:192:168::/48 snat ip6 prefix to 2001:470:e997::/48'';
      }
    ];
  };

  # Preserve the old block-outbound-src-ports behavior for this host: drop
  # locally-generated SSDP/mDNS (sport 5353) leaving via the WAN interface.
  lantian.firewall.chains.ZONE_WAN_OUTPUT.rules = [
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
      text = ''fib saddr type local oifname "eth1*" jump ZONE_WAN_OUTPUT'';
    }
  ];
}
