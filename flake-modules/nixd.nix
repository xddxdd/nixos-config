{
  self,
  inputs,
  ...
}:
let
  patchedPkgsFor = system: self.allSystems."${system}"._module.args.pkgs;
in
{
  flake = {
    homeConfigurations = {
      "_nixd" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = patchedPkgsFor "x86_64-linux";
        modules = [
          {
            home.stateVersion = "24.05";
            home.username = "user";
            home.homeDirectory = "/home/user";
          }
        ];
      };
    };
  };
}
