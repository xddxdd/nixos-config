{ inputs, ... }:

let
  userConfig = {
    imports = [
      ./home.nix
      inputs.nixos-vscode-server.nixosModules.homeManager
    ];
    services.auto-fix-vscode-server.enable = true;
  };
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
