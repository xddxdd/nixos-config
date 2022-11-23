{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../helpers args;
in
{
  imports =
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
    in
    [ ]
    ++ (ls ./common-apps)
    ++ (ls ./client-apps)
  ;
}
