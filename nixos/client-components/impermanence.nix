{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
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

        # XDG config folders
        ".cache"
        ".config"
        ".local"

        # Important config
        ".gnupg"
        ".ssh"

        # Other configs
        ".android"
        ".conda"
        ".kde4"
        ".kube"
        ".librewolf"
        ".mozilla"
        ".rustup"
        ".stack"
        ".steam"

        ".thunderbird"
        ".vagrant.d"
        ".vscode"
        ".wine"
        ".zoom"
      ];
      files = [ ];
    };
  };
}
