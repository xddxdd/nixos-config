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
    nur.url = github:nix-community/NUR;
    nur-xddxdd = {
      url = github:xddxdd/nur-packages;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, deploy-rs, ... }@inputs:
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
    nixosConfigurations = {
      "nixos" = defaultSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos/configuration.nix
        ];
      };
    };

    deploy = {
      sshUser = "root";
      user = "root";
      sshOpts = [ "-p" "2222" ];

      nodes = {
        "nixos" = {
          hostname = "192.168.56.105";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."nixos";
            magicRollback = false;
          };
        };
      };
    };
  };
}
