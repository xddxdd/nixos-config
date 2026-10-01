{
  pkgs,
  LT,
  ...
}:
{
  imports = [
    # ./kamailio.nix
    ./open5gs-certs.nix
    ./osmo.nix
    ./pyhss.nix
    ./rtpengine.nix
    ./services.nix
  ];

  # environment.etc."freeDiameter/hss.conf".source = ./freeDiameter/hss.conf;
  environment.etc."freeDiameter/mme.conf".source = ./freeDiameter/mme.conf;
  environment.etc."freeDiameter/pcrf.conf".source = ./freeDiameter/pcrf.conf;
  environment.etc."freeDiameter/smf.conf".source = ./freeDiameter/smf.conf;
  environment.etc."freeDiameter/lib".source = "${pkgs.open5gs}/lib/freeDiameter";

  networking.hosts = {
    "127.0.0.2" = [ "mme.epc.mnc010.mcc315.3gppnetwork.org" ];
    "127.0.0.4" = [ "smf.epc.mnc010.mcc315.3gppnetwork.org" ];
    "127.0.0.8" = [ "hss.epc.mnc010.mcc315.3gppnetwork.org" ];
    "127.0.0.9" = [ "pcrf.epc.mnc010.mcc315.3gppnetwork.org" ];
  };

  systemd.network.netdevs.open5gs = {
    netdevConfig = {
      Kind = "tun";
      Name = "ogstun";
    };
  };

  systemd.network.networks.open5gs = {
    address = [
      "192.168.4.1/24"
      "2001:470:e997:4000::1/52"
    ];
    linkConfig = {
      MTUBytes = 1400;
      RequiredForOnline = false;
    };
    matchConfig.Name = "ogstun";
  };

  lantian.firewall.chains.FILTER_INPUT.rules = [
    {
      priority = LT.firewallPriorities.preService;
      text = ''
        iifname "ogstun" tcp dport 853 reject
        iifname "ogstun" udp dport 853 reject
      '';
    }
  ];
  lantian.firewall.chains.NAT_PREROUTING.dnat =
    map
      (proto: {
        priority = LT.firewallPriorities.preService;
        matches = [ ''iifname "ogstun" ${proto} dport 53'' ];
        ipv4 = "192.168.0.1:53";
        ipv6 = "[fc00:192:168::1]:53";
      })
      [
        "tcp"
        "udp"
      ];
}
