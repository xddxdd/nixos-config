{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/intel-undervolt.nix
    ../../nixos/optional-apps/libvirt
    ../../nixos/optional-apps/netease-cloud-music.nix
    ../../nixos/optional-apps/netns-wg-lantian.nix
    ../../nixos/optional-apps/nvidia/prime.nix
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

  lantian.hidpi = 1.25;

  fileSystems."/".options = [ "size=100%" ];

  services.beesd.filesystems.root = {
    spec = config.fileSystems."/nix".device;
    hashTableSizeMB = 64;
    verbosity = "crit";
    extraOptions = [ "--thread-count" "2" "--loadavg-target" "4" ];
  };

  services.tlp.settings = {
    CPU_MIN_PERF_ON_AC = lib.mkForce "0";
    CPU_MAX_PERF_ON_AC = lib.mkForce "50";
    CPU_MIN_PERF_ON_BAT = lib.mkForce "0";
    CPU_MAX_PERF_ON_BAT = lib.mkForce "50";
  };

  services.yggdrasil.regions = [ "united-states" "canada" ];
}
