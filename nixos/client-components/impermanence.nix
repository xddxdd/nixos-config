{ LT, config, ... }:
{
  preservation.preserveAt."/nix/persistent" = {
    commonMountOptions = [
      "x-gvfs-hide"
      "x-gdu.hide"
    ];
    users.lantian = {
      directories = builtins.map LT.preservation.mkFolder (
        builtins.filter (v: !(config.fileSystems ? "/home/lantian/${v}")) [
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
          ".cache/KDE/neochat" # NeoChat
          ".cache/mesa_shader_cache" # Intel GPU Shader Cache
          ".cache/netease-cloud-music/Cef" # NetEase Cloud Music Login State
          ".cache/nvidia" # NVIDIA GPU Shader Cache

          # XDG config folders
          ".config"
          ".local"

          # Important config
          ".gnupg"
          ".ssh"

          # Other configs
          ".aMule"
          ".antigravity"
          ".ApacheDirectoryStudio"
          ".aws"
          ".cherrystudio"
          ".conda"
          ".cursor"
          ".gemini"
          ".ghidra"
          ".java/.userPrefs" # DBeaver
          ".kube"
          ".librewolf"
          ".mozilla/firefox"
          ".openfaas"
          ".parsec"
          ".pcem"
          ".qwen"
          ".roo"
          ".runpod"
          ".steam"
          ".terraform.d"
          ".thunderbird"
          ".vscode"
          ".vscode-server"
          ".windsurf"
          ".Xilinx"
          ".zoom"
        ]
      );
      files = builtins.map LT.preservation.mkFile [ ];
    };
  };

  # Impermanence will copy permissions from source dir
  # Chown to lantian:lantian
  systemd.tmpfiles.settings = {
    "home-lantian" = {
      "/nix/persistent/home/lantian"."d" = {
        mode = "0700";
        user = "lantian";
        group = "lantian";
      };
    };
  };
}
