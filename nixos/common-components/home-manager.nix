{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  perUserConfig = {
    home.stateVersion = LT.constants.stateVersion;
    imports =
      if builtins.elem LT.tags.client LT.this.tags
      then [../../home/client.nix]
      else [../../home/none.nix];
  };
in {
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    users.root = perUserConfig;
    users.lantian = perUserConfig;
  };
}
