{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  home.packages = with pkgs; [
    colmena
    flake.agenix.packages."${system}".agenix
    nix-tree
    nodePackages.node2nix
    nvfetcher
    rnix-lsp
  ];
}
