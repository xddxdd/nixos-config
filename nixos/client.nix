{ config, pkgs, lib, ... }:

let
  LT = import ../helpers { inherit config pkgs lib; };
  homeConfig = import ../home/client.nix {
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
    ++ (ls ./client-apps)
    ++ (ls ./common-components)
    ++ (ls ./client-components)
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
