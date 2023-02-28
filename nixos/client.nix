{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  homeConfig = import ../home/client.nix (args
    // {
      lib = lib // {inherit (inputs.home-manager.lib) hm;};
    });
in {
  imports = let
    ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
  in
    []
    ++ (ls ./common-apps)
    ++ (ls ./client-apps)
    ++ (ls ./common-components)
    ++ (ls ./client-components);

  home-manager.users.root = {
    home.stateVersion = LT.constants.stateVersion;
    imports = [homeConfig];
  };
  home-manager.users.lantian = {
    home.stateVersion = LT.constants.stateVersion;
    imports = [homeConfig];
  };
}
