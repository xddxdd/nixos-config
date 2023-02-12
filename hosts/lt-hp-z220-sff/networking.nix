{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  mkSRIOVConfig = nicID: vfID: ''
    [SR-IOV]
    VirtualFunction=${builtins.toString vfID}
    MACSpoofCheck=no
    Trust=yes
    MACAddress=42:42:42:25:47:${builtins.toString nicID}${builtins.toString vfID}
  '';

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
in
{
  # SR-IOV
  boot.extraModprobeConfig = ''
    options igb max_vfs=7
    options vfio-pci ids=8086:1520
  '';
  boot.blacklistedKernelModules = [ "igbvf" ];
  boot.kernelModules = [ "vfio-pci" ];

  # # Alternative way to set VF number
  # services.udev.extraRules = ''
  #   ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x1521", ATTR{sriov_numvfs}="7"
  # '';

  ########################################
  # LAN
  ########################################

  systemd.network.networks.eth0-onboard = {
    networkConfig.Bridge = "wan-br";
    matchConfig = {
      PermanentMACAddress = "6c:3b:e5:16:65:b3";
      Driver = "e1000e";
    };
  };

  systemd.network.networks.eth0-i350 = {
    networkConfig.Bond = "wan-bond";
    matchConfig = {
      PermanentMACAddress = "a0:36:9f:36:f0:bc";
      Driver = "igb";
    };
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 0) 7);
  };

  systemd.network.networks.eth1-i350 = {
    networkConfig.Bond = "wan-bond";
    matchConfig = {
      PermanentMACAddress = "a0:36:9f:36:f0:bd";
      Driver = "igb";
    };
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 1) 7);
  };

  systemd.network.networks.eth2-i350 = {
    networkConfig.Bond = "wan-bond";
    matchConfig = {
      PermanentMACAddress = "a0:36:9f:36:f0:be";
      Driver = "igb";
    };
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 2) 7);
  };

  systemd.network.networks.eth3-i350 = {
    networkConfig.Bond = "wan-bond";
    matchConfig = {
      PermanentMACAddress = "a0:36:9f:36:f0:bf";
      Driver = "igb";
    };
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 3) 7);
  };

  systemd.network.netdevs.wan-bond = {
    netdevConfig = {
      Kind = "bond";
      Name = "wan-bond";
    };
    bondConfig = {
      Mode = "balance-alb";
      TransmitHashPolicy = "encap3+4";
    };
  };

  systemd.network.networks.wan-bond = {
    matchConfig.Name = "wan-bond";
    networkConfig.Bridge = "wan-br";
  };

  systemd.network.netdevs.wan-br = {
    netdevConfig = {
      Kind = "bridge";
      Name = "wan-br";
    };
    extraConfig = ''
      [Bridge]
      STP=yes
    '';
  };

  systemd.network.networks.wan-br = {
    matchConfig.Name = "wan-br";
    address = [ "192.168.0.2/24" ];
    gateway = [ "192.168.0.1" ];
    networkConfig.DHCP = "no";
  };

  # Wi-Fi AP
  systemd.network.networks.wlan0 = {
    networkConfig.Bridge = "wan-br";
    matchConfig.Name = "wlan0";
  };

  systemd.network.networks.wlan1 = {
    networkConfig.Bridge = "wan-br";
    matchConfig.Name = "wlan1";
  };

  # 6GHz
  systemd.services.hostapd-wlan1 = mkHostapd "wlan1" ''
    driver=nl80211

    ssid=Lan Tian Test 6GHz
    wpa=2
    wpa_key_mgmt=SAE
    wpa_passphrase=9876547210.33
    rsn_pairwise=CCMP
    group_cipher=CCMP

    hw_mode=a
    ieee80211w=2
    beacon_prot=1
    ieee80211ax=1
    he_su_beamformer=1
    he_su_beamformee=1
    he_mu_beamformer=1
    he_oper_chwidth=2
    unsol_bcast_probe_resp_interval=20

    channel=1
    op_class=134
    he_oper_centr_freq_seg0_idx=15

    country_code=CA
    country3=0x04
    # ieee80211d=1
    # ieee80211h=1
  '';

  # # 5GHz
  # systemd.services.hostapd-wlan1 = mkHostapd "wlan1" ''
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
  #   vht_capab=[MAX-MPDU-11454][VHT160][RXLDPC][SHORT-GI-80][SHORT-GI-160][TX-STBC-2BY1][SU-BEAMFORMER][SU-BEAMFORMEE][MU-BEAMFORMER][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]
  #   ieee80211ax=1

  #   channel=36
  #   vht_oper_chwidth=1
  #   vht_oper_centr_freq_seg0_idx=42

  #   country_code=CA
  #   country3=0x04
  #   # ieee80211d=1
  #   # ieee80211h=1
  # '';

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

    country_code=CA
    country3=0x04
    # ieee80211d=1
    # ieee80211h=1
  '';

}
