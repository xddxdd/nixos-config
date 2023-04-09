{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args:
lib.mkIf (!config.boot.isContainer) {
  environment.persistence."/nix/persistent" = {
    hideMounts = true;
    users.lantian = {
      directories = [
        # Personal folders
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Projects"
        "Videos"
        "VirtualBox VMs"

        # Preserved cache
        ".cache/com.github.tchar.calculate-anything" # Ulauncher calculator plugin
        ".cache/mesa_shader_cache" # Intel GPU Shader Cache
        ".cache/netease-cloud-music/Cef" # NetEase Cloud Music Login State
        ".cache/nix-index" # nix-index index data
        ".cache/nvidia" # NVIDIA GPU Shader Cache
        ".cache/tldr-python" # Ulauncher TLDR plugin

        # XDG config folders
        ".config"
        ".local"

        # Important config
        ".gnupg"
        ".ssh"

        # Other configs
        ".android"
        ".conda"
        ".fly"
        ".kde4"
        ".kube"
        ".librewolf"
        ".mozilla"
        ".pcem"
        ".rustup"
        ".stack"
        ".steam"
        ".thunderbird"
        ".vagrant.d"
        ".vscode"
        ".wine"
        ".Xilinx"
        ".zoom"
      ];
      files = [];
    };
  };
}
