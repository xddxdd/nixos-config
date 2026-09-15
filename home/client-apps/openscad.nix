{ pkgs, ... }:
{
  home.packages = [
    pkgs.openscad-unstable
    pkgs.openscad-lsp
    pkgs.openscadPackages.bosl
    pkgs.openscadPackages.bosl2
  ];
}
