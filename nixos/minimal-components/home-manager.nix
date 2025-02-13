{ LT, inputs, ... }:
let
  entrypoint = if LT.this.hasTag LT.tags.client then ../../home/client.nix else ../../home/none.nix;

  perUserConfig = {
    home.stateVersion = LT.constants.stateVersion;
    home.enableNixpkgsReleaseCheck = false;
    imports = [ entrypoint ];
  };
in
{
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];

    users.root = perUserConfig;
    users.lantian = perUserConfig;
  };
}
