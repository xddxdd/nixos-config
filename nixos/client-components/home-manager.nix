{
  LT,
  lib,
  inputs,
  self,
  pkgsWithCuda,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    extraSpecialArgs = {
      inherit
        self
        inputs
        pkgsWithCuda
        LT
        ;
    };
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    users = lib.genAttrs [ "root" "lantian" ] (user: {
      home.stateVersion = LT.constants.stateVersion;
      home.enableNixpkgsReleaseCheck = false;
      home.username = user;
      imports = [ ../../home/client.nix ];
    });
  };
}
