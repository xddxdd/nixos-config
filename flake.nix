{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vscode-server = {
      url ="github:iosmanthus/nixos-vscode-server/add-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  let
    defaultSystem = { system ? "x86_64-linux", modules ? [], overlay ? true }@config: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./common/common.nix
        ./hosts/nixos/configuration.nix
        (import ./common/home-manager.nix { inherit inputs; })
      ];
    };
  in {
    nixosConfigurations."nixos" = defaultSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nixos/configuration.nix
      ];
    };
  };
}
