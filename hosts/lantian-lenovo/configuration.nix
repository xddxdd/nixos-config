{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix

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

  services.yggdrasil.config.Peers = LT.yggdrasil [ "united-states" "canada" ];
}
