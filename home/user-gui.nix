{ inputs, overlays, stateVersion, ... }:

{ config, pkgs, ... }:

{
  imports = [
    (import ./user.nix { inherit inputs overlays stateVersion; })
    ./components/conky.nix
    ./components/fcitx.nix
    ./components/fonts-archlinux.nix
    ./components/mpv.nix
  ];

  services.auto-fix-vscode-server.enable = pkgs.lib.mkForce false;

  programs.git.signing = {
    key = "27F31700E751EC22";
    gpgPath = "/usr/bin/gpg";
    signByDefault = true;
  };

  home.packages = with pkgs; [
    colmena
    inputs.agenix.packages."${system}".agenix
    rnix-lsp
  ];
}
