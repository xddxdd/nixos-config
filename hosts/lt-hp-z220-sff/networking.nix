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
    matchConfig.Name = "ens3f0";
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 0) 7);
  };

  systemd.network.networks.ens3f1 = {
    address = [
      "192.168.1.3/24"
      "2001:470:e89e:1::3/64"
    ];
    networkConfig.DHCP = "no";
    matchConfig.Name = "ens3f1";
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 1) 7);
  };

  systemd.network.networks.ens3f2 = {
    address = [
      "192.168.1.4/24"
      "2001:470:e89e:1::4/64"
    ];
    networkConfig.DHCP = "no";
    matchConfig.Name = "ens3f2";
    extraConfig = builtins.concatStringsSep "\n" (builtins.genList (mkSRIOVConfig 2) 7);
  };

  systemd.network.networks.ens3f3 = {
    address = [
      "192.168.1.5/24"
      "2001:470:e89e:1::5/64"
    ];
    networkConfig.DHCP = "no";
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
