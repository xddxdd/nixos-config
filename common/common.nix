{ config, pkgs, modules, ... }:

let
  LT = import ./helpers.nix { inherit config pkgs; };
in
{
  imports =
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
    in
    (ls ./required-apps) ++ (ls ./required-components);
}
