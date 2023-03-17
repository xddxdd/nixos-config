{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
    ./media-center.nix

    ../../nixos/hardware/ignore-nice-load.nix

    ../../nixos/client-components/network-manager.nix

    ../../nixos/optional-apps/intel-undervolt.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/cuda-only.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/vlmcsd.nix
  ];

  networking.networkmanager.unmanaged = lib.mkForce [
    "interface-name:*,except:interface-name:wl*"
  ];

  systemd.network.networks."eth0" = {
    address = ["192.168.0.6/24" "2001:470:e825::6/64"];
    gateway = ["192.168.0.2" "2001:470:e825::2"];
    matchConfig.Name = "eth0";
  };

  environment.etc."intel-undervolt.conf".text = ''
    undervolt 0 'CPU' -100
    undervolt 1 'GPU' -100
    undervolt 2 'CPU Cache' -100
    undervolt 3 'System Agent' -100
    undervolt 4 'Analog I/O' 0
  '';

  environment.persistence."/nix/persistent".directories = [
    "/home/lantian"
  ];

  services.tlp.settings = {
    TLP_DEFAULT_MODE = "BAT";
    TLP_PERSISTENT_DEFAULT = 1;
  };

  fileSystems."/".options = ["size=100%"];

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 64;
    verbosity = "crit";
    extraOptions = ["--thread-count" "2" "--loadavg-target" "4"];
  };

  # Mount samba share
  age.secrets.samba-credentials.file = inputs.secrets + "/samba-credentials.age";
  fileSystems."/mnt/storage" = {
    device = "//192.168.0.2/storage";
    fsType = "cifs";
    options = [
      "nofail"
      "credentials=${config.age.secrets.samba-credentials.path}"
    ];
  };

  # Intel SGX
  services.aesmd.enable = true;
  hardware.cpu.intel.sgx = {
    provision.enable = true;
    enableDcapCompat = true;
  };
}
