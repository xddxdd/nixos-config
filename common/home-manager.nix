{ inputs, stateVersion, ... }:

{ pkgs, ... }:

let
  userConfig = {
    imports = [
      inputs.nixos-vscode-server.nixosModules.homeManager
    ];

    home.file.".zshrc".text = ''
      # Created by home-manager
    '';
    home.stateVersion = stateVersion;

    programs.home-manager.enable = true;
    programs.git = {
      enable = true;
      userName = "Lan Tian";
      userEmail = "xuyh0120@outlook.com";
    };

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
