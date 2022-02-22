{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/libvirt.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/x11vnc.nix
  ];

  environment.systemPackages = with pkgs; [
    aria
    colmena
    discord
    firefox
    google-chrome
    mpv
    nixos-cn.netease-cloud-music
    rnix-lsp
    tdesktop
    thunderbird
    tilix
    vscode
    wpsoffice
    zoom-us
  ];

  programs.steam.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  services.beesd.filesystems.root = {
    spec = "/nix";
    hashTableSizeMB = 512;
    verbosity = "crit";
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
