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
      "50kvm" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/50kvm/configuration.nix
        ];
      };
      "buyvm" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/buyvm/configuration.nix
        ];
      };
      "hostdare" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/hostdare/configuration.nix
        ];
      };
      "oracle-vm1" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/oracle-vm1/configuration.nix
        ];
      };
      "oracle-vm2" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/oracle-vm2/configuration.nix
        ];
      };
      "oracle-vm-arm" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/oracle-vm-arm/configuration.nix
        ];
      };
      "soyoustart" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/soyoustart/configuration.nix
        ];
      };
      "virmach-ny1g" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/virmach-ny1g/configuration.nix
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
      "virtono-old" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.agenix.nixosModules.age
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs; })
          ./hosts/virtono-old/configuration.nix
        ];
      };
    };

    deploy = {
      sshUser = "root";
      user = "root";
      autoRollback = false;
      magicRollback = false;

      nodes = {
        "50kvm" = {
          hostname = "50kvm.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."50kvm";
            sshOpts = [ "-p" "2222" ];
          };
        };
        "buyvm" = {
          hostname = "buyvm.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."buyvm";
            sshOpts = [ "-p" "2222" ];
          };
        };
        "hostdare" = {
          hostname = "hostdare.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."hostdare";
            sshOpts = [ "-p" "2222" ];
          };
        };
        "oracle-vm1" = {
          hostname = "oracle-vm1.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."oracle-vm1";
            sshOpts = [ "-p" "2222" ];
          };
        };
        "oracle-vm2" = {
          hostname = "oracle-vm2.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."oracle-vm2";
            sshOpts = [ "-p" "2222" ];
          };
        };
        "oracle-vm-arm" = {
          hostname = "oracle-vm-arm.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations."oracle-vm-arm";
            sshOpts = [ "-p" "2222" ];
          };
        };
        "soyoustart" = {
          hostname = "soyoustart.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."soyoustart";
            sshOpts = [ "-p" "2222" ];
          };
        };
        "virmach-ny1g" = {
          hostname = "virmach-ny1g.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."virmach-ny1g";
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
        "virtono-old" = {
          hostname = "virtono-old.lantian.pub";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."virtono-old";
            sshOpts = [ "-p" "2222" ];
          };
        };
      };
    };
  };
}
