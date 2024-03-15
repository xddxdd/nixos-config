{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  entrypoint =
    if LT.this.hasTag LT.tags.client then ../../home/client.nix else ../../home/none.nix;

  perUserConfig = {
    home.stateVersion = LT.constants.stateVersion;
    imports = [ entrypoint ];
  };
in
{
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    users.root = perUserConfig;
    users.lantian = perUserConfig;
  };
}
