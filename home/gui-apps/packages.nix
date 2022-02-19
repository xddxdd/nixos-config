{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    colmena
    pkgs.flake.agenix.packages."${system}".agenix
    nodePackages.node2nix
    nvfetcher-bin
    rnix-lsp
  ];
}
