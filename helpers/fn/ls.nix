{
  config,
  pkgs,
  lib,
  ...
}:
dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir))
