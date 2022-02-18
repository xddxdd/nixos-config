{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    # Common libraries
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    dwarffs = {
      url = "github:edolstra/dwarffs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cn = {
      url = "github:nixos-cn/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
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

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      lib = nixpkgs.lib;
      hosts = import ./hosts.nix;
      roles = import helpers/roles.nix;
      hostsList = builtins.filter (k: (hosts."${k}".role or roles.server) != roles.non-nixos) (lib.attrNames hosts);

      stateVersion = "21.05";

      overlays = [
        (final: prev: {
          flake = inputs;
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
        inputs.colmena.overlay
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
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            networking.hostName = n;
            nixpkgs = { inherit system overlays; };
            system.stateVersion = stateVersion;
          })
          inputs.agenix.nixosModules.age
          inputs.dwarffs.nixosModules.dwarffs
          ({ lib, config, ... }: inputs.flake-utils-plus.nixosModules.autoGenFromInputs { inherit lib config inputs; })
          inputs.home-manager.nixosModules.home-manager
          inputs.impermanence.nixosModules.impermanence
          inputs.nix-ld.nixosModules.nix-ld
          inputs.nixos-cn.nixosModules.nixos-cn
          (./hosts + "/${n}/configuration.nix")
        ];

      eachSystem = flake-utils.lib.eachSystemMap flake-utils.lib.allSystems;
    in
    {
      nixosConfigurations = lib.genAttrs hostsList
        (n: lib.nixosSystem {
          system = systemFor n;
          modules = modulesFor n;
        });

      packages = eachSystem (system: {
        homeConfigurations =
          let
            cfg = attrs: inputs.home-manager.lib.homeManagerConfiguration ({
              inherit stateVersion system;
              configuration = { config, pkgs, lib, ... }: {
                nixpkgs.overlays = overlays;
                home.stateVersion = stateVersion;
                imports = [ home/non-nixos.nix ];
              };
            } // attrs);
          in
          {
            lantian = cfg rec {
              username = "lantian";
              homeDirectory = "/home/${username}";
            };
            root = cfg rec {
              username = "root";
              homeDirectory = "/root";
            };
          };

        dnsRecords = import ./dns {
          pkgs = import nixpkgs { inherit system; };
        };
      });

      colmena = {
        meta.nixpkgs = { inherit lib; };
        meta.nodeNixpkgs = lib.genAttrs hostsList (n: import nixpkgs { system = systemFor n; });
      } // (lib.genAttrs hostsList (n: {
        deployment = {
          targetHost = hostnameFor n;
          targetPort = sshPortFor n;
          targetUser = "root";
        };

        imports = modulesFor n;
      }));

      nixosCD = import ./nixos/nixos-cd.nix { inherit inputs overlays stateVersion; };
    };
}
