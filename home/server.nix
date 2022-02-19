{ config, pkgs, lib, ... }:

let
  LT = import ../helpers { inherit config pkgs; };
in
{
  imports =
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
    in
    [ ]
    ++ (ls ./common-apps)
  ;
}
