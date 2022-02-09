{ inputs, overlays, stateVersion, ... }:

{ config, pkgs, ... }:

{
  imports = [
    (import ./user.nix { inherit inputs overlays stateVersion; })
    ./components/ansible.nix
    ./components/conky.nix
    ./components/fcitx.nix
    ./components/fonts-archlinux.nix
    ./components/looking-glass.nix
    ./components/mpv.nix
    ./components/profile-sync-daemon.nix
    ./components/reset-touchpad.nix
    ./components/wayland.nix
  ];

  services.auto-fix-vscode-server.enable = pkgs.lib.mkForce false;

  programs.git.signing = {
    key = "B50EC319385FCB0D";
    gpgPath = "/usr/bin/gpg";
    signByDefault = true;
  };

  home.packages = with pkgs; [
    colmena
    inputs.agenix.packages."${system}".agenix
    nodePackages.node2nix
    nvfetcher-bin
    rnix-lsp
  ];
}
