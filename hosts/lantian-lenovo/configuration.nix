{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/gui-apps.nix
    ../../nixos/optional-apps/intel-undervolt.nix
    ../../nixos/optional-apps/netease-cloud-music.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/nvidia/prime.nix
    ../../nixos/optional-apps/obs-studio.nix
    ../../nixos/optional-apps/resilio.nix
    ../../nixos/optional-apps/transmission-daemon.nix
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

  lantian.hidpi = 1.25;

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
  };

  services.transmission.settings.download-dir = "/mnt/usb/downloads";
  systemd.services.transmission = {
    after = [ "mnt-usb.mount" ];
    requires = [ "mnt-usb.mount" ];
  };

  virtualisation.kvmgt = {
    enable = true;
    vgpus.i915-GVTg_V5_4.uuid = [
      (LT.uuid "Intel GVT-g 1")
    ];
  };

  services.yggdrasil.regions = [ "united-states" "canada" ];
}
