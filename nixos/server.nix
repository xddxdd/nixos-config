{ config, pkgs, lib, ... }:

let
  LT = import ../helpers { inherit config pkgs lib; };
  homeConfig = import ../home/server.nix {
    inherit config pkgs;
    lib = lib // { inherit (pkgs.flake.home-manager.lib) hm; };
  };
in
{
  imports =
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
    in
    [ ]
    ++ (ls ./common-apps)
    ++ (ls ./server-apps)
    ++ (ls ./common-components)
    ++ (ls ./server-components)
  ;

  home-manager.users.root = {
    home.stateVersion = LT.constants.stateVersion;
    imports = [ homeConfig ];
  };
  home-manager.users.lantian = {
    home.stateVersion = LT.constants.stateVersion;
    imports = [ homeConfig ];
  };
}
