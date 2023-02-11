{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  mkSRIOVConfig = nicID: vfID: ''
    [SR-IOV]
    VirtualFunction=${builtins.toString vfID}
    MACSpoofCheck=no
    Trust=yes
    MACAddress=42:42:42:25:47:${builtins.toString nicID}${builtins.toString vfID}
  '';
in
{
  # Handle multiple NICs
  networking.usePredictableInterfaceNames = lib.mkForce true;

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

  systemd.network.networks.eno1 = {
    networkConfig.Bridge = "wan-br";
    matchConfig.Name = "eno1";
  };

  systemd.network.networks.ens3f0 = {
    networkConfig.Bond = "wan-bond";
    matchConfig.Name = "ens3f0";
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 0) 7);
  };

  systemd.network.networks.ens3f1 = {
    networkConfig.Bond = "wan-bond";
    matchConfig.Name = "ens3f1";
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 1) 7);
  };

  systemd.network.networks.ens3f2 = {
    networkConfig.Bond = "wan-bond";
    matchConfig.Name = "ens3f2";
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 2) 7);
  };

  systemd.network.networks.ens3f3 = {
    networkConfig.Bond = "wan-bond";
    matchConfig.Name = "ens3f3";
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
  };

  systemd.network.networks.wan-br = {
    matchConfig.Name = "wan-br";
    address = [
      "192.168.0.2/24"
      "2001:470:e89e::2/64"
    ];
    gateway = [ "192.168.0.1" ];
    networkConfig.DHCP = "no";
  };

  # Wi-Fi AP
  systemd.network.networks.wlan1 = {
    networkConfig.Bridge = "wan-br";
    matchConfig.Name = "wlan1";
  };

  # # Disable for interface name changing across reboots
  # systemd.services.hostapd-wlan1 =
  #   let
  #     cfg = pkgs.writeText "hostapd.conf" ''
  #       interface=wlan1
  #       bridge=wan-br
  #       driver=nl80211

  #       ssid=Lan Tian 6GHz
  #       wpa=2
  #       wpa_key_mgmt=SAE
  #       wpa_passphrase=9876547210.33
  #       rsn_pairwise=CCMP
  #       group_cipher=CCMP

  #       hw_mode=a
  #       ieee80211w=2
  #       beacon_prot=1
  #       ieee80211ax=1
  #       he_su_beamformer=1
  #       he_su_beamformee=1
  #       he_mu_beamformer=1
  #       he_oper_chwidth=2

  #       channel=1
  #       op_class=134
  #       he_oper_centr_freq_seg0_idx=15

  #       country_code=CA
  #       ieee80211d=1
  #       ieee80211h=1

  #       ctrl_interface=/run/hostapd-wlan1
  #       ctrl_interface_group=wheel

  #       noscan=1
  #     '';
  #     # cfg = pkgs.writeText "hostapd.conf" ''
  #     #   interface=wlan1
  #     #   driver=nl80211

  #     #   ssid=Lan Tian Test
  #     #   wpa=2
  #     #   wpa_key_mgmt=WPA-PSK
  #     #   wpa_passphrase=9876547210.33
  #     #   rsn_pairwise=CCMP
  #     #   group_cipher=CCMP

  #     #   hw_mode=a
  #     #   # wmm_enabled=1
  #     #   # ieee80211w=2
  #     #   # beacon_prot=1
  #     #   ieee80211n=1
  #     #   ieee80211ac=1
  #     #   ht_capab=[HT40+]

  #     #   channel=36
  #     #   vht_oper_chwidth=1
  #     #   vht_oper_centr_freq_seg0_idx=42

  #     #   country_code=CA
  #     #   ieee80211d=1
  #     #   ieee80211h=1

  #     #   ctrl_interface=/run/hostapd-wlan1
  #     #   ctrl_interface_group=wheel

  #     #   noscan=1
  #     # '';
  #   in
  #   {
  #     path = [ pkgs.hostapd ];
  #     # after = [ "sys-subsystem-net-devices-wlan1.device" ];
  #     # bindsTo = [ "sys-subsystem-net-devices-wlan1.device" ];
  #     # requiredBy = [ "network-link-wlan1.service" ];
  #     wantedBy = [ "multi-user.target" ];

  #     serviceConfig = {
  #       ExecStart = "${pkgs.hostapd}/bin/hostapd ${cfg}";
  #       Restart = "always";
  #     };
  #   };
}
