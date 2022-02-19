{ config, pkgs, ... }:

{
  imports = [
    ./server.nix

    ./components/ansible.nix
    ./components/conky.nix
    ./components/fcitx.nix
    ./components/fonts.nix
    ./components/himawaripy.nix
    ./components/looking-glass.nix
    ./components/mpv.nix
    ./components/profile-sync-daemon.nix
    ./components/reset-touchpad.nix
    ./components/ulauncher-extensions.nix
    ./components/xdg-user-dirs.nix
  ];

  programs.git.signing = {
    key = "B50EC319385FCB0D";
    gpgPath = "/usr/bin/gpg";
    signByDefault = true;
  };

  home.packages = with pkgs; [
    colmena
    pkgs.flake.agenix.packages."${system}".agenix
    nodePackages.node2nix
    nvfetcher-bin
    rnix-lsp
  ];
}
