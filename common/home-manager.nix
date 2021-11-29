{ inputs, stateVersion, ... }:

let
  userConfig = import ../home/user.nix { inherit inputs stateVersion; };
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.root = userConfig;
  home-manager.users.lantian = userConfig;
}
