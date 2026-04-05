{ pkgs, LT, ... }:
{
  home.packages = [
    pkgs.openscad
    pkgs.openscad-lsp
  ];

  xdg.dataFile."OpenSCAD/libraries/BOSL2".source = LT.sources.bosl2.src;
}
