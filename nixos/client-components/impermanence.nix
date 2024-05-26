_: {
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
        ".cache/nvidia" # NVIDIA GPU Shader Cache
        ".cache/tldr-python" # Ulauncher TLDR plugin

        # XDG config folders
        ".config"
        ".local"

        # Important config
        ".gnupg"
        ".ssh"

        # Other configs
        ".aMule"
        ".android"
        ".conda"
        ".fly"
        ".ghidra"
        ".kde4"
        ".kube"
        ".librewolf"
        ".mozilla"
        ".openfaas"
        ".parsec"
        ".pcem"
        ".runpod"
        ".rustup"
        ".stack"
        ".steam"
        ".terraform.d"
        ".thunderbird"
        ".vagrant.d"
        ".vscode"
        ".wine"
        ".Xilinx"
        ".zoom"
      ];
      files = [ ];
    };
  };

  # Impermanence will copy permissions from source dir
  # Chown to lantian:lantian
  systemd.tmpfiles.rules = [ "d /nix/persistent/home/lantian 700 lantian lantian" ];
}
