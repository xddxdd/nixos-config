{
  LT,
  lib,
  inputs,
  ...
}:
let
  entrypoint = if LT.this.hasTag LT.tags.client then ../../home/client.nix else ../../home/none.nix;

  perUserConfig = user: {
    home.stateVersion = LT.constants.stateVersion;
    home.enableNixpkgsReleaseCheck = false;
    home.username = user;
    imports = [ entrypoint ];
  };
in
{
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

    users = lib.genAttrs [ "root" "lantian" ] perUserConfig;
  };
}
