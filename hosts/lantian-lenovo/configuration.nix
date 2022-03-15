{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/gui-apps.nix
    ../../nixos/optional-apps/intel-undervolt.nix
    ../../nixos/optional-apps/ipfs-client.nix
    ../../nixos/optional-apps/netease-cloud-music.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/libvirt.nix
    ../../nixos/optional-apps/obs-studio.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/x11vnc.nix
  ];

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

  fileSystems."/".options = [ "size=100%" ];

  services.beesd.filesystems.root = {
    spec = "/nix";
    hashTableSizeMB = 512;
    verbosity = "crit";
    extraOptions = [ "-c" "2" ];
  };

  services.tlp.settings = {
    # Use powersave scheduler for intel_pstate
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    # On battery GPU is locked to min frequency
    INTEL_GPU_MIN_FREQ_ON_AC = 350;
    INTEL_GPU_MIN_FREQ_ON_BAT = 350;
    INTEL_GPU_MAX_FREQ_ON_AC = 1100;
    INTEL_GPU_MAX_FREQ_ON_BAT = 350;
    INTEL_GPU_BOOST_FREQ_ON_AC = 1100;
    INTEL_GPU_BOOST_FREQ_ON_BAT = 350;
  };

  virtualisation.kvmgt = {
    enable = true;
    vgpus.i915-GVTg_V5_8.uuid = [
      (LT.uuid "Intel GVT-g 1")
      (LT.uuid "Intel GVT-g 2")
    ];
  };

  services.yggdrasil.config.Peers = LT.yggdrasil [ "united-states" "canada" ];
}
