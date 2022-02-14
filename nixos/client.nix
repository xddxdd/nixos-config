{ config, pkgs, lib, ... }:

let
  LT = import ../helpers { inherit config pkgs; };
  homeConfig = import ../home/client.nix {
    inherit config pkgs;
    lib = lib // { hm = pkgs.flake.home-manager.lib.hm; };
  };
in
{
  imports =
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
    in
    [ ]
    ++ (ls ./common-apps)
    ++ (ls ./common-components)
  ;

  home-manager.users.root = homeConfig;
  home-manager.users.lantian = homeConfig;
}
