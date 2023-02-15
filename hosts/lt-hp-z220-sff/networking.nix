{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  mkRouteTable = table: routes: builtins.map
    (r: {
      routeConfig = {
        Destination = r;
        Table = table;
      };
    })
    routes;

  mkRoutingPolicy = table: ips: builtins.map
    (ip: {
      routingPolicyRuleConfig = {
        From = builtins.head (lib.splitString "/" ip);
        Table = table;
      };
    })
    ips;

  mkHostapd = interface: cfg: {
    path = [ pkgs.hostapd ];
    after = [ "sys-subsystem-net-devices-${interface}.device" ];
    bindsTo = [ "sys-subsystem-net-devices-${interface}.device" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig =
      let
        cfgFile = pkgs.writeText "hostapd.conf" (''
          interface=${interface}
          ctrl_interface=/run/hostapd-${interface}
          ctrl_interface_group=wheel
        '' + cfg);
      in
      {
        ExecStart = "${pkgs.hostapd}/bin/hostapd ${cfgFile}";
        Restart = "always";
      };
  };

  onboard = "6c:3b:e5:16:65:b3";
  i350-1 = "a0:36:9f:36:f0:bc";
  i350-2 = "a0:36:9f:36:f0:bd";
  i350-3 = "a0:36:9f:36:f0:be";
  i350-4 = "a0:36:9f:36:f0:bf";

  mkLANRouteTable = table: mkRouteTable table [ "192.168.0.0/24" "2001:470:e825::/64" ];
in
{
  # SR-IOV
  boot.extraModprobeConfig = ''
    options vfio-pci ids=8086:1520
  '';
  boot.blacklistedKernelModules = [ "igbvf" ];
  boot.kernelModules = [ "vfio-pci" ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${i350-1}", NAME="eth-i350-1", ATTR{device/sriov_numvfs}="7"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${i350-2}", NAME="eth-i350-2", ATTR{device/sriov_numvfs}="7"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${i350-3}", NAME="eth-i350-3", ATTR{device/sriov_numvfs}="7"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${i350-4}", NAME="eth-i350-4", ATTR{device/sriov_numvfs}="7"
  '';

  ########################################
  # CenturyLink Uplink
  ########################################

  systemd.network.networks.onboard = {
    networkConfig = {
      DHCP = "no";
      VLAN = [ "wan.201" ];
    };
    matchConfig = {
      PermanentMACAddress = onboard;
      Driver = "e1000e";
    };
  };

  systemd.network.netdevs."wan.201" = {
    netdevConfig = {
      Kind = "vlan";
      Name = "wan.201";
    };
    vlanConfig = {
      Id = 201;
    };
  };

  systemd.network.networks."wan.201" = {
    networkConfig = {
      DHCP = "yes";
      Tunnel = "henet";
    };
    matchConfig.Name = "wan.201";
  };

  ########################################
  # LAN
  ########################################

  systemd.network.networks.dummy0.address = [
    "192.168.0.2/32"
    "192.168.0.3/32"
    "192.168.0.4/32"
    "192.168.0.5/32"
  ];

  systemd.network.networks.i350-1 = {
    networkConfig.Bridge = "lan-br";
    matchConfig = {
      PermanentMACAddress = i350-1;
      Driver = "igb";
    };
  };

  systemd.network.networks.i350-2 = rec {
    address = [ "192.168.0.3/24" "2001:470:e825::3/64" ];
    matchConfig = {
      PermanentMACAddress = i350-2;
      Driver = "igb";
    };
    routes = mkLANRouteTable 32;
    routingPolicyRules = mkRoutingPolicy 32 address;
  };

  systemd.network.networks.i350-3 = rec {
    address = [ "192.168.0.4/24" "2001:470:e825::4/64" ];
    matchConfig = {
      PermanentMACAddress = i350-3;
      Driver = "igb";
    };
    routes = mkLANRouteTable 33;
    routingPolicyRules = mkRoutingPolicy 33 address;
  };

  systemd.network.networks.i350-4 = rec {
    address = [ "192.168.0.5/24" "2001:470:e825::5/64" ];
    matchConfig = {
      PermanentMACAddress = i350-4;
      Driver = "igb";
    };
    routes = mkLANRouteTable 34;
    routingPolicyRules = mkRoutingPolicy 34 address;
  };

  systemd.network.netdevs.lan-br = {
    netdevConfig = {
      Kind = "bridge";
      Name = "lan-br";
    };
    extraConfig = ''
      [Bridge]
      STP=yes
    '';
  };

  systemd.network.networks.lan-br = rec {
    matchConfig.Name = "lan-br";
    address = [ "192.168.0.2/24" "2001:470:e825::2/64" ];
    networkConfig = {
      DHCP = "no";
      DHCPServer = "yes";
    };
    dhcpServerConfig = {
      PoolOffset = 10;
      PoolSize = 200;
      EmitDNS = "yes";
      DNS = config.networking.nameservers;
    };
    routes = mkLANRouteTable 31;
    routingPolicyRules = mkRoutingPolicy 31 address;
  };

  services.miniupnpd = {
    internalIPs = [
      "192.168.0.2"
      "192.168.0.3"
      "192.168.0.4"
      "192.168.0.5"
    ];
    externalInterface = "wan.201";
  };

  # Wi-Fi AP
  systemd.network.networks.wlan0 = {
    networkConfig.Bridge = "lan-br";
    matchConfig.Name = "wlan0";
  };

  systemd.network.networks.wlan1 = {
    networkConfig.Bridge = "lan-br";
    matchConfig.Name = "wlan1";
  };

  # # 6GHz
  # systemd.services.hostapd-wlan1 = mkHostapd "wlan1" ''
  #   driver=nl80211

  #   ssid=Lan Tian Test 6GHz
  #   wpa=2
  #   wpa_key_mgmt=SAE
  #   wpa_passphrase=9876547210.33
  #   rsn_pairwise=CCMP
  #   group_cipher=CCMP

  #   hw_mode=a
  #   ieee80211w=2
  #   beacon_prot=1
  #   ieee80211ax=1
  #   he_su_beamformer=1
  #   he_su_beamformee=1
  #   he_mu_beamformer=1
  #   he_oper_chwidth=2
  #   unsol_bcast_probe_resp_interval=20

  #   channel=1
  #   op_class=134
  #   he_oper_centr_freq_seg0_idx=15

  #   country_code=US
  #   country3=0x04
  #   # ieee80211d=1
  #   # ieee80211h=1
  # '';

  # 5GHz
  systemd.services.hostapd-wlan1 = mkHostapd "wlan1" ''
    driver=nl80211

    ssid=Lan Tian Test 5GHz
    wpa=2
    wpa_key_mgmt=WPA-PSK WPA-PSK-SHA256 SAE
    wpa_passphrase=9876547210.33
    rsn_pairwise=CCMP
    group_cipher=CCMP

    hw_mode=a
    wmm_enabled=1
    ieee80211w=2
    beacon_prot=1

    ieee80211n=1
    ht_capab=[LDPC][HT40+][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935]
    ieee80211ac=1
    # Disable beamforming for weird antenna setup
    vht_capab=[MAX-MPDU-11454][VHT160][RXLDPC][SHORT-GI-80][SHORT-GI-160][TX-STBC-2BY1][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]
    ieee80211ax=1

    channel=149
    vht_oper_chwidth=2
    vht_oper_centr_freq_seg0_idx=163

    country_code=US
    country3=0x04
    ieee80211d=1
    ieee80211h=1
  '';

  # 2.4GHz
  systemd.services.hostapd-wlan0 = mkHostapd "wlan0" ''
    driver=nl80211

    ssid=Lan Tian Test 2.4GHz
    wpa=2
    wpa_key_mgmt=WPA-PSK WPA-PSK-SHA256 SAE
    wpa_passphrase=9876547210.33
    rsn_pairwise=CCMP
    group_cipher=CCMP

    hw_mode=g
    ieee80211w=2
    beacon_prot=1

    ieee80211n=1
    ht_capab=[LDPC][HT40+][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935]

    channel=acs_survey
    acs_num_scans=5

    country_code=US
    country3=0x04
    ieee80211d=1
    ieee80211h=1
  '';

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
      "2001:470:a:50::2/64"
      "2001:470:b:50::1/64"
      "2001:470:e825::1/48"
    ];
    gateway = [ "2001:470:a:50::1" ];
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
