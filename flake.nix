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
    hath-nix.url = github:poscat0x04/hath-nix;
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # sops-nix = {
    #   url = github:Mic92/sops-nix;
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, nur, deploy-rs, ... }@inputs:
  {
    nixosConfigurations = {
      "soyoustart" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/soyoustart/configuration.nix
        ];
      };
      "virmach-ny6g" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/virmach-ny6g/configuration.nix
        ];
      };
      "virmach-nl1g" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/virmach-nl1g/configuration.nix
        ];
      };
    };

    deploy = {
      sshUser = "root";
      user = "root";
      autoRollback = false;
      magicRollback = false;

      nodes = {
        "soyoustart" = {
          hostname = "soyoustart.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."soyoustart";
            sshOpts = [ "-p" "2222" ];
          };
        };
        "virmach-ny6g" = {
          hostname = "virmach-ny6g.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."virmach-ny6g";
            sshOpts = [ "-p" "2222" ];
          };
        };
        "virmach-nl1g" = {
          hostname = "virmach-nl1g.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."virmach-nl1g";
            sshOpts = [ "-p" "2222" ];
          };
        };
      };
    };
  };
}
