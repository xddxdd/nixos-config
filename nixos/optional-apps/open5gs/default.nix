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

  boot.availableKernelModules = [
    "sctp"
    "tun"
  ];

  # mariadb-install-db chowns its already mysql-owned data directory.
  systemd.services.mysql.serviceConfig.SystemCallFilter = [
    "@system-service"
    "~@clock @cpu-emulation @debug @module @mount @obsolete @raw-io @reboot @swap"
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

  # Networkd restarts are disabled globally; reload to pick up the new TUN files.
  systemd.services.systemd-networkd.reloadIfChanged = true;

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

  # UE traffic from the 5G tunnel: it may reach WAN, and DNS is redirected to
  # the host resolver. Nothing may forward into this zone.
  lantian.firewall.zones.OGSTUN = {
    interfaces = [ "ogstun" ];
    forwardTo = [ "WAN" ];
    tcpPorts = {
      "${LT.portStr.DNS}" = {
        type = "forward";
        ipv4 = "192.168.0.1";
        ipv6 = "fc00:192:168::1";
      };
      "853" = {
        type = "reject";
      };
    };
    udpPorts = {
      "${LT.portStr.DNS}" = {
        type = "forward";
        ipv4 = "192.168.0.1";
        ipv6 = "fc00:192:168::1";
      };
      "853" = {
        type = "reject";
      };
    };
  };
}
