{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../helpers args;
  homeConfig = import ../home/server.nix (args // {
    lib = lib // { inherit (inputs.home-manager.lib) hm; };
  });
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

  home-manager.users.root = {
    home.stateVersion = LT.constants.stateVersion;
    imports = [ homeConfig ];
  };
  home-manager.users.lantian = {
    home.stateVersion = LT.constants.stateVersion;
    imports = [ homeConfig ];
  };
}
