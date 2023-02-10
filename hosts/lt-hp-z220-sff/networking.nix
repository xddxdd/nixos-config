{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  mkRouteTable = table: route4: route6: [
    {
      routeConfig = {
        Destination = route4;
        Table = table;
      };
    }
    {
      routeConfig = {
        Destination = route6;
        Table = table;
      };
    }
  ];

  mkRoutingPolicy = table: ipv4: ipv6: [
    {
      routingPolicyRuleConfig = {
        From = ipv4;
        Table = table;
      };
    }
    {
      routingPolicyRuleConfig = {
        From = ipv6;
        Table = table;
      };
    }
  ];

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
      "2001:470:e89e:1::2/64"
    ];
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
    routes = mkRouteTable 30 "192.168.1.0/24" "2001:470:e89e:1::/64";
    routingPolicyRules = mkRoutingPolicy 30 "192.168.1.2" "2001:470:e89e:1::2";
    matchConfig.Name = "ens3f0";
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 0) 7);
  };

  systemd.network.networks.ens3f1 = {
    address = [
      "192.168.1.3/24"
      "2001:470:e89e:1::3/64"
    ];
    networkConfig.DHCP = "no";
    routes = mkRouteTable 31 "192.168.1.0/24" "2001:470:e89e:1::/64";
    routingPolicyRules = mkRoutingPolicy 31 "192.168.1.3" "2001:470:e89e:1::3";
    matchConfig.Name = "ens3f1";
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 1) 7);
  };

  systemd.network.networks.ens3f2 = {
    address = [
      "192.168.1.4/24"
      "2001:470:e89e:1::4/64"
    ];
    networkConfig.DHCP = "no";
    routes = mkRouteTable 32 "192.168.1.0/24" "2001:470:e89e:1::/64";
    routingPolicyRules = mkRoutingPolicy 32 "192.168.1.4" "2001:470:e89e:1::4";
    matchConfig.Name = "ens3f2";
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 2) 7);
  };

  systemd.network.networks.ens3f3 = {
    address = [
      "192.168.1.5/24"
      "2001:470:e89e:1::5/64"
    ];
    networkConfig.DHCP = "no";
    routes = mkRouteTable 33 "192.168.1.0/24" "2001:470:e89e:1::/64";
    routingPolicyRules = mkRoutingPolicy 33 "192.168.1.5" "2001:470:e89e:1::5";
    matchConfig.Name = "ens3f3";
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 3) 7);
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

  # Wi-Fi AP
  # Disabled, not working well

  # systemd.network.networks.wlan1 = {
  #   address = [
  #     "192.168.2.1/24"
  #   ];
  #   networkConfig = {
  #     DHCP = "no";
  #     DHCPServer = "yes";
  #   };
  #   dhcpServerConfig = {
  #     PoolOffset = 10;
  #     PoolSize = 200;
  #     EmitDNS = "yes";
  #     DNS = config.networking.nameservers;
  #   };
  #   matchConfig.Name = "wlan1";
  # };

  # systemd.services.hostapd-wlan1 =
  #   let
  #     # cfg = pkgs.writeText "hostapd.conf" ''
  #     #   interface=wlan1
  #     #   driver=nl80211

  #     #   ssid=Lan Tian Test
  #     #   wpa=2
  #     #   wpa_key_mgmt=SAE
  #     #   wpa_passphrase=9876547210.33
  #     #   rsn_pairwise=CCMP
  #     #   group_cipher=CCMP

  #     #   hw_mode=a
  #     #   # wmm_enabled=1
  #     #   # ieee80211n=1
  #     #   # ieee80211ac=1
  #     #   ieee80211w=2
  #     #   beacon_prot=1
  #     #   ieee80211ax=1
  #     #   # vht_oper_chwidth=2
  #     #   # he_su_beamformer=1
  #     #   # he_su_beamformee=1
  #     #   # he_mu_beamformer=1
  #     #   # he_oper_chwidth=2

  #     #   channel=1
  #     #   op_class=134
  #     #   he_oper_centr_freq_seg0_idx=15

  #     #   country_code=CA
  #     #   ieee80211d=1

  #     #   ctrl_interface=/run/hostapd-wlan1
  #     #   ctrl_interface_group=wheel

  #     #   noscan=1
  #     # '';
  #     cfg = pkgs.writeText "hostapd.conf" ''
  #       interface=wlan1
  #       driver=nl80211

  #       ssid=Lan Tian Test
  #       wpa=2
  #       wpa_key_mgmt=WPA-PSK
  #       wpa_passphrase=9876547210.33
  #       rsn_pairwise=CCMP
  #       group_cipher=CCMP

  #       hw_mode=a
  #       # wmm_enabled=1
  #       # ieee80211w=2
  #       # beacon_prot=1
  #       ieee80211n=1
  #       ieee80211ac=1
  #       ht_capab=[HT40+]

  #       channel=36
  #       vht_oper_chwidth=1
  #       vht_oper_centr_freq_seg0_idx=42

  #       country_code=CA
  #       ieee80211d=1
  #       ieee80211h=1

  #       ctrl_interface=/run/hostapd-wlan1
  #       ctrl_interface_group=wheel

  #       noscan=1
  #     '';
  #   in
  #   {
  #     path = [ pkgs.hostapd ];
  #     # after = [ "sys-subsystem-net-devices-wlan1.device" ];
  #     # bindsTo = [ "sys-subsystem-net-devices-wlan1.device" ];
  #     requiredBy = [ "network-link-wlan1.service" ];
  #     wantedBy = [ "multi-user.target" ];

  #     serviceConfig = {
  #       ExecStart = "${pkgs.hostapd}/bin/hostapd ${cfg}";
  #       Restart = "always";
  #     };
  #   };

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
