{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    colmena
    flake.agenix.packages."${system}".agenix
    nix-tree
    nodePackages.node2nix
    nvfetcher-bin
    rnix-lsp
  ];
}
