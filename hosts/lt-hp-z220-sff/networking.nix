{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  # Handle multiple NICs
  networking.usePredictableInterfaceNames = lib.mkForce true;

  ########################################
  # CenturyLink Uplink
  ########################################

  systemd.network.networks.eno1 = {
    networkConfig = {
      DHCP = "no";
      VLAN = [ "eno1.201" ];
    };
    matchConfig.Name = "eno1";
  };

  systemd.network.netdevs."eno1.201" = {
    netdevConfig = {
      Kind = "vlan";
      Name = "eno1.201";
    };
    vlanConfig = {
      Id = 201;
    };
  };

  systemd.network.networks."eno1.201" = {
    networkConfig = {
      DHCP = "yes";
      Tunnel = "henet";
    };
    matchConfig.Name = "eno1.201";
  };

  ########################################
  # LAN
  ########################################

  systemd.network.networks.dummy0.address = [
    "192.168.1.2/32"
    "192.168.1.3/32"
    "192.168.1.4/32"
    "192.168.1.5/32"
  ];

  systemd.network.networks.ens3f0 = {
    address = [
      "192.168.1.2/24"
      "2001:470:e89e:2::1/64"
    ];
    ipv6Prefixes = [{
      ipv6PrefixConfig.Prefix = "2001:470:e89e:2::/64";
    }];
    networkConfig = {
      DHCP = "no";
      DHCPServer = "yes";
      IPv6SendRA = "yes";
    };
    dhcpServerConfig = {
      PoolOffset = 10;
      PoolSize = 200;
      EmitDNS = "yes";
      DNS = config.networking.nameservers;
    };
    matchConfig.Name = "ens3f0";
  };

  systemd.network.networks.ens3f1 = {
    address = [
      "192.168.1.3/24"
      "2001:470:e89e:3::1/64"
    ];
    networkConfig.DHCP = "no";
    matchConfig.Name = "ens3f1";
  };

  systemd.network.networks.ens3f2 = {
    address = [
      "192.168.1.4/24"
      "2001:470:e89e:4::1/64"
    ];
    networkConfig.DHCP = "no";
    matchConfig.Name = "ens3f2";
  };

  systemd.network.networks.ens3f3 = {
    address = [
      "192.168.1.5/24"
      "2001:470:e89e:5::1/64"
    ];
    networkConfig.DHCP = "no";
    matchConfig.Name = "ens3f3";
  };

  services.miniupnpd = {
    internalIPs = [
      "192.168.1.2"
      "192.168.1.3"
      "192.168.1.4"
      "192.168.1.5"
    ];
    externalInterface = "eno1.201";
  };

  ########################################
  # HE.NET Tunnelbroker
  ########################################

  systemd.network.netdevs.henet = {
    netdevConfig = {
      Kind = "sit";
      Name = "henet";
    };
    tunnelConfig = {
      Local = "dhcp4";
      Remote = "216.218.226.238";
      TTL = 255;
    };
  };

  systemd.network.networks.henet = {
    address = [
      "2001:470:a:1a6::2/64"
      "2001:470:b:1a6::1/64"
      "2001:470:e89e::1/48"
    ];
    gateway = [ "2001:470:a:1a6::1" ];
    matchConfig.Name = "henet";
  };

  age.secrets.henet-update-ip.file = inputs.secrets + "/henet-update-ip-lt-hp-z220-sff.age";

  systemd.services.henet-update-ip = {
    after = [ "network.target" ];
    requires = [ "network.target" ];
    script = ''
      URL=$(cat "${config.age.secrets.henet-update-ip.path}")
      exec ${pkgs.curl}/bin/curl "$URL"
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.timers.henet-update-ip = {
    wantedBy = [ "timers.target" ];
    partOf = [ "henet-update-ip.service" ];
    timerConfig = {
      OnCalendar = "*:0/15";
      Persistent = true;
      Unit = "henet-update-ip.service";
    };
  };
}
