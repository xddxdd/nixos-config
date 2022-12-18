{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    # Common libraries
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-22-05.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    cities-json = {
      url = "github:lutangar/cities.json";
      flake = false;
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dwarffs = {
      url = "github:edolstra/dwarffs";
      inputs.nix.follows = "nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    nix = {
      url = "github:NixOS/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-asterisk-music = {
      url = "git+ssh://git@git.lantian.pub:2222/lantian/nixos-asterisk-music.git";
      flake = false;
    };
    nixos-cn = {
      url = "github:nixos-cn/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nur.url = "github:nix-community/NUR";
    nur-xddxdd = {
      # url = "/home/lantian/Projects/nur-packages";
      url = "github:xddxdd/nur-packages";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/xddxdd/nixos-secrets";
      flake = false;
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

  outputs = { self, flake-utils, ... }@inputs:
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
      inherit (inputs.flake-utils-plus.lib.mkFlake {
        inherit self inputs;
        supportedSystems = flake-utils.lib.allSystems;
        channels.nixpkgs = {
          config = {
            allowUnfree = true;
            # contentAddressedByDefault = true;
          };
          input = inputs.nixpkgs;
          patches = ls ./patches/nixpkgs;
        };
        outputsBuilder = channels: channels;
      }) nixpkgs;

      inherit (nixpkgs."x86_64-linux") lib;
      LT = import ./helpers { inherit lib inputs; };
      specialArgs = { inherit inputs; };

      modulesFor = n:
        let
          inherit (LT.hosts."${n}") system hostname sshPort role manualDeploy;
        in
        [
          ({ config, ... }: {
            deployment = {
              allowLocalDeployment = role == LT.roles.client;
              targetHost = hostname;
              targetPort = sshPort;
              targetUser = "root";
              tags = [ role ] ++ (lib.optional (!manualDeploy) "default");
            };
            home-manager = {
              backupFileExtension = "bak";
              extraSpecialArgs = specialArgs;
              useGlobalPkgs = true;
              useUserPackages = true;
            };
            nixpkgs = {
              overlays = [
                inputs.colmena.overlay
                inputs.nix-alien.overlay
                inputs.nixos-cn.overlay
                (inputs.nur-xddxdd.overlays.custom
                  config.boot.kernelPackages.nvidia_x11)
              ] ++ (import ./overlays { inherit inputs lib; });
              pkgs = nixpkgs."${system}";
            };
            networking.hostName = n;
            system.stateVersion = LT.constants.stateVersion;
          })
          inputs.agenix.nixosModules.age
          inputs.dwarffs.nixosModules.dwarffs
          inputs.flake-utils-plus.nixosModules.autoGenFromInputs
          inputs.impermanence.nixosModules.impermanence
          inputs.home-manager.nixosModules.home-manager
          inputs.nur-xddxdd.nixosModules.qemu-user-static-binfmt
        ] ++ [
          (./hosts + "/${n}/configuration.nix")
        ];

      extraModulesFor = n: [
        inputs.colmena.nixosModules.deploymentOptions
      ];

      eachSystem = flake-utils.lib.eachSystemMap flake-utils.lib.allSystems;
    in
    rec {
      nixosConfigurations = lib.mapAttrs
        (n: { system, ... }:
          inputs.nixpkgs.lib.nixosSystem {
            inherit system specialArgs;
            modules = modulesFor n;
            extraModules = extraModulesFor n;
          })
        LT.hosts;

      packages = eachSystem (system: {
        homeConfigurations =
          let
            cfg = attrs: inputs.home-manager.lib.homeManagerConfiguration ({
              inherit system;
              inherit (LT.constants) stateVersion;
              configuration = { config, pkgs, lib, ... }: {
                home.stateVersion = LT.constants.stateVersion;
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

        nixosCD = import ./nixos/nixos-cd.nix {
          inherit inputs nixpkgs lib system;
          inherit (LT) constants;
        };
      });

      colmena = {
        meta.allowApplyAll = false;
        meta.nixpkgs = { inherit lib; };
        meta.nodeNixpkgs = lib.mapAttrs (n: { system, ... }: nixpkgs."${system}") LT.nixosHosts;
        meta.specialArgs = specialArgs;
      } // (lib.mapAttrs (n: v: { imports = modulesFor n; }) LT.nixosHosts);

      apps = eachSystem (system:
        let
          pkgs = nixpkgs."${system}";
          mkApp = path: {
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "script" (pkgs.callPackage path specialArgs));
          };
        in
        {
          colmena = mkApp ./scripts/colmena.nix;
          check = mkApp ./scripts/check.nix;
          dnscontrol = mkApp ./scripts/dnscontrol.nix;
          gcore = mkApp ./scripts/gcore;
          nvfetcher = mkApp ./scripts/nvfetcher.nix;
          update = mkApp ./scripts/update.nix;
        });
    };
}
