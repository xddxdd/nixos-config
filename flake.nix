{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    # Common libraries
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vscode-server = {
      url = "github:iosmanthus/nixos-vscode-server/add-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nur.url = github:nix-community/NUR;
    nur-xddxdd = {
      url = github:xddxdd/nur-packages;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      hosts = import ./hosts.nix;
      hostsList = builtins.filter (k: hosts."${k}".deploy or true) (lib.attrNames hosts);

      stateVersion = "21.05";
      nixosCD = import ./common/nixos-cd.nix { inherit inputs overlays stateVersion; };

      overlays = [
        (final: prev: {
          flake = inputs;
          nixos-cd-lantian = nixosCD;
          rage = prev.stdenv.mkDerivation rec {
            name = "rage";
            version = prev.age.version;

            phases = [ "installPhase" ];
            installPhase = ''
              mkdir -p $out/bin
              ln -s ${prev.age}/bin/age $out/bin/rage
              ln -s ${prev.age}/bin/age-keygen $out/bin/rage-keygen
            '';
          };
        })
        inputs.nur-xddxdd.overlay
        inputs.nvfetcher.overlay
      ];

      systemFor = n: hosts."${n}".system or "x86_64-linux";
      hostnameFor = n: hosts."${n}".hostname or "${n}.lantian.pub";
      sshPortFor = n: hosts."${n}".sshPort or 2222;

      modulesFor = n:
        let
          system = systemFor n;
        in
        [
          ({
            networking.hostName = n;
            nixpkgs = { inherit system overlays; };
            system.stateVersion = stateVersion;
          })
          inputs.agenix.nixosModules.age
          ({ lib, config, ... }: inputs.flake-utils-plus.nixosModules.autoGenFromInputs { inherit lib config inputs; })
          inputs.impermanence.nixosModules.impermanence
          inputs.nixos-vscode-server.nixosModules.system
          ./common/common.nix
          (import ./common/home-manager.nix { inherit inputs overlays stateVersion; })
          (./hosts + "/${n}/configuration.nix")
        ];
    in
    {
      nixosConfigurations = lib.genAttrs hostsList
        (n: lib.nixosSystem {
          system = systemFor n;
          modules = modulesFor n;
        });

      homeConfigurations = {
        lantian = inputs.home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-linux";
          username = "lantian";
          homeDirectory = "/home/${username}";
          inherit stateVersion;
          # FIXME: Support remote deploy to GUI systems
          configuration = import ./home/user-gui.nix { inherit inputs overlays stateVersion; };
        };
        root = inputs.home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-linux";
          username = "root";
          homeDirectory = "/root";
          inherit stateVersion;
          # FIXME: Support remote deploy to GUI systems
          configuration = import ./home/user-gui.nix { inherit inputs overlays stateVersion; };
        };
      };
      lantian = self.homeConfigurations.lantian.activationPackage;
      root = self.homeConfigurations.root.activationPackage;

      colmena = {
        meta.nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
      } // (lib.genAttrs hostsList
        (n: {
          deployment = {
            targetHost = hostnameFor n;
            targetPort = sshPortFor n;
            targetUser = "root";
          };

          imports = modulesFor n;
        }));

      dnsRecords = import ./dns/toplevel.nix {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      };

      inherit nixosCD;
    };
}
