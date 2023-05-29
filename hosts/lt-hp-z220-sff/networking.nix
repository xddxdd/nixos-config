{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  mkHostapd = interface: cfg: {
    path = [pkgs.hostapd];
    wantedBy = ["multi-user.target"];

    serviceConfig = let
      cfgFile = pkgs.writeText "hostapd.conf" (''
          interface=${interface}
          ctrl_interface=/run/hostapd-${interface}
          ctrl_interface_group=wheel
        ''
        + cfg);
    in {
      ExecStart = "${pkgs.hostapd}/bin/hostapd ${cfgFile}";
      Restart = "always";
    };
  };

  board = "6c:3b:e5:16:65:b3";
  i350-1 = "a0:36:9f:36:f0:bc";
  i350-2 = "a0:36:9f:36:f0:bd";
  i350-3 = "a0:36:9f:36:f0:be";
  i350-4 = "a0:36:9f:36:f0:bf";
  i225v = "88:c9:b3:b5:04:83";
  mt7916-2_4g = "00:0a:52:08:38:2e";
  mt7916-5g = "00:0a:52:08:38:2f";
in {
  # SR-IOV
  boot.extraModprobeConfig = ''
    options vfio-pci ids=8086:1520
  '';
  boot.blacklistedKernelModules = ["igbvf"];
  boot.kernelModules = ["vfio-pci"];

  # Do not use eth* as name, they are reserved for WAN ports
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${i350-1}", NAME="lan-i350-1", ATTR{device/sriov_numvfs}="7"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${i350-2}", NAME="lan-i350-2", ATTR{device/sriov_numvfs}="7"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${i350-3}", NAME="lan-i350-3", ATTR{device/sriov_numvfs}="7"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${i350-4}", NAME="lan-i350-4", ATTR{device/sriov_numvfs}="7"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${i225v}", NAME="lan-i225v"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${mt7916-2_4g}", NAME="wlan-2_4g"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${mt7916-5g}", NAME="wlan-5g"
  '';

  ########################################
  # CenturyLink Uplink
  ########################################

  systemd.network.networks.eth-board = {
    networkConfig = {
      DHCP = "no";
      VLAN = ["eth-board.201"];
    };
    matchConfig = {
      PermanentMACAddress = board;
      Driver = "e1000e";
    };
  };

  systemd.network.netdevs."eth-board.201" = {
    netdevConfig = {
      Kind = "vlan";
      Name = "eth-board.201";
    };
    vlanConfig = {
      Id = 201;
    };
  };

  systemd.network.networks."eth-board.201" = {
    networkConfig = {
      DHCP = "yes";
      Tunnel = "henet";
    };
    matchConfig.Name = "eth-board.201";
  };

  ########################################
  # LAN
  ########################################

  systemd.network.networks.dummy0.address = [
    "192.168.0.2/32"
  ];

  systemd.network.networks.lan-i350-1 = {
    networkConfig.Bond = "lan-bond";
    matchConfig = {
      PermanentMACAddress = i350-1;
      Driver = "igb";
    };
  };

  systemd.network.networks.lan-i350-2 = {
    networkConfig.Bond = "lan-bond";
    matchConfig = {
      PermanentMACAddress = i350-2;
      Driver = "igb";
    };
  };

  systemd.network.networks.lan-i350-3 = {
    networkConfig.Bond = "lan-bond";
    matchConfig = {
      PermanentMACAddress = i350-3;
      Driver = "igb";
    };
  };

  systemd.network.networks.lan-i350-4 = {
    networkConfig.Bond = "lan-bond";
    matchConfig = {
      PermanentMACAddress = i350-4;
      Driver = "igb";
    };
  };

  systemd.network.networks.lan-i225v = {
    networkConfig.Bridge = "lan-br";
    matchConfig = {
      PermanentMACAddress = i225v;
      Driver = "igc";
    };
  };

  systemd.network.netdevs.lan-bond = {
    netdevConfig = {
      Kind = "bond";
      Name = "lan-bond";
    };
    bondConfig = {
      Mode = "balance-alb";
      TransmitHashPolicy = "encap3+4";
    };
  };

  systemd.network.networks.lan-bond = {
    matchConfig.Name = "lan-bond";
    networkConfig.Bridge = "lan-br";
  };

  systemd.network.netdevs.lan-br = {
    netdevConfig = {
      Kind = "bridge";
      Name = "lan-br";
    };
    extraConfig = ''
      [Bridge]
      HairPin=yes
      STP=yes
    '';
  };

  systemd.network.networks.lan-br = {
    matchConfig.Name = "lan-br";
    address = ["192.168.0.2/24" "198.19.102.1/24" "2001:470:e825::2/64"];
    networkConfig = {
      DHCP = "no";
      DHCPServer = "yes";
    };
    dhcpServerConfig = {
      ServerAddress = "198.19.102.1/24";
      PoolOffset = 100;
      PoolSize = 100;
      EmitDNS = "yes";
      DNS = config.networking.nameservers;
    };
  };

  services.miniupnpd = {
    internalIPs = ["192.168.0.2" "198.19.102.1"];
    externalInterface = "eth-board.201";
  };

  # # Wi-Fi AP
  # systemd.network.networks.wlan-2_4g = {
  #   networkConfig.Bridge = "lan-br";
  #   matchConfig.Name = "wlan-2_4g";
  # };

  # systemd.network.networks.wlan-5g = {
  #   networkConfig.Bridge = "lan-br";
  #   matchConfig.Name = "wlan-5g";
  # };

  # # # 6GHz
  # # systemd.services.hostapd-wlan-5g = mkHostapd "wlan-5g" ''
  # #   driver=nl80211

  # #   ssid=Lan Tian Test 6GHz
  # #   wpa=2
  # #   wpa_key_mgmt=SAE
  # #   wpa_passphrase=9876547210.33
  # #   rsn_pairwise=CCMP
  # #   group_cipher=CCMP

  # #   hw_mode=a
  # #   ieee80211w=2
  # #   beacon_prot=1
  # #   ieee80211ax=1
  # #   he_su_beamformer=1
  # #   he_su_beamformee=1
  # #   he_mu_beamformer=1
  # #   he_oper_chwidth=2
  # #   unsol_bcast_probe_resp_interval=20

  # #   channel=1
  # #   op_class=134
  # #   he_oper_centr_freq_seg0_idx=15

  # #   country_code=US
  # #   country3=0x04
  # #   # ieee80211d=1
  # #   # ieee80211h=1
  # # '';

  # # 5GHz
  # systemd.services.hostapd-wlan-5g = mkHostapd "wlan-5g" ''
  #   driver=nl80211

  #   ssid=Lan Tian Test 5GHz
  #   wpa=2
  #   wpa_key_mgmt=WPA-PSK WPA-PSK-SHA256 SAE
  #   wpa_passphrase=9876547210.33
  #   rsn_pairwise=CCMP
  #   group_cipher=CCMP

  #   hw_mode=a
  #   wmm_enabled=1
  #   ieee80211w=2
  #   beacon_prot=1

  #   ieee80211n=1
  #   ht_capab=[LDPC][HT40+][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935]
  #   ieee80211ac=1
  #   # Disable beamforming for weird antenna setup
  #   vht_capab=[MAX-MPDU-11454][VHT160][RXLDPC][SHORT-GI-80][SHORT-GI-160][TX-STBC-2BY1][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]
  #   ieee80211ax=1

  #   channel=149
  #   vht_oper_chwidth=2
  #   vht_oper_centr_freq_seg0_idx=163

  #   country_code=US
  #   country3=0x04
  #   ieee80211d=1
  #   ieee80211h=1
  # '';

  # # 2.4GHz
  # systemd.services.hostapd-wlan-2_4g = mkHostapd "wlan-2_4g" ''
  #   driver=nl80211

  #   ssid=Lan Tian Test 2.4GHz
  #   wpa=2
  #   wpa_key_mgmt=WPA-PSK WPA-PSK-SHA256 SAE
  #   wpa_passphrase=9876547210.33
  #   rsn_pairwise=CCMP
  #   group_cipher=CCMP

  #   hw_mode=g
  #   ieee80211w=2
  #   beacon_prot=1

  #   ieee80211n=1
  #   ht_capab=[LDPC][HT40+][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935]

  #   channel=acs_survey
  #   acs_num_scans=5

  #   country_code=US
  #   country3=0x04
  #   ieee80211d=1
  #   ieee80211h=1
  # '';

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
    gateway = ["2001:470:a:50::1"];
    matchConfig.Name = "henet";
  };

  age.secrets.henet-update-ip.file = inputs.secrets + "/henet-update-ip-lt-hp-z220-sff.age";

  systemd.services.henet-update-ip = {
    after = ["network.target"];
    requires = ["network.target"];
    script = ''
      URL=$(cat "${config.age.secrets.henet-update-ip.path}")
      exec ${pkgs.curl}/bin/curl "$URL"
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.timers.henet-update-ip = {
    wantedBy = ["timers.target"];
    partOf = ["henet-update-ip.service"];
    timerConfig = {
      OnCalendar = "*:0/15";
      Persistent = true;
      Unit = "henet-update-ip.service";
    };
  };
}
