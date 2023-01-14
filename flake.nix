{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    # Common libraries
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-22-05.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-22-11.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    impermanence.url = "github:nix-community/impermanence";
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
    srvos = {
      url = "github:numtide/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, flake-utils-plus, ... }@inputs:
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));

      inherit (inputs.nixpkgs) lib;
      LT = import ./helpers { inherit lib inputs; };
      specialArgsFor = n: {
        inherit inputs;
        LT = import ./helpers {
          inherit lib inputs;
          inherit (self.nixosConfigurations."${n}") config pkgs;
        };
      };

      modulesFor = n: [
        ({ config, ... }: {
          deployment =
            let
              inherit (LT.hosts."${n}" or (LT.hostDefaults n { })) hostname sshPort role manualDeploy;
            in
            {
              allowLocalDeployment = role == LT.roles.client;
              targetHost = hostname;
              targetPort = sshPort;
              targetUser = "root";
              tags = [ role ] ++ (lib.optional (!manualDeploy) "default");
            };
          home-manager = {
            backupFileExtension = "bak";
            extraSpecialArgs = specialArgsFor n;
            useGlobalPkgs = true;
            useUserPackages = true;
          };
          nixpkgs = {
            overlays = [
              inputs.colmena.overlay
              inputs.nix-alien.overlay
              inputs.nixos-cn.overlay
            ] ++ (import ./overlays { inherit inputs; });
          };
          networking.hostName = lib.mkForce (lib.removePrefix "_" n);
          system.stateVersion = LT.constants.stateVersion;
        })
        inputs.agenix.nixosModules.age
        inputs.colmena.nixosModules.deploymentOptions
        inputs.dwarffs.nixosModules.dwarffs
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.home-manager
        inputs.nur-xddxdd.nixosModules.setupOverlay
        inputs.nur-xddxdd.nixosModules.qemu-user-static-binfmt
        inputs.srvos.nixosModules.common
        (./hosts + "/${n}/configuration.nix")
      ];

      # https://github.com/zhaofengli/colmena/blob/main/src/nix/hive/eval.nix
      mkColmenaHive = metaConfig: nodes: with builtins; rec {
        __schema = "v0";
        inherit metaConfig nodes;

        toplevel = lib.mapAttrs (_: v: v.config.system.build.toplevel) nodes;
        deploymentConfig = lib.mapAttrs (_: v: v.config.deployment) nodes;
        deploymentConfigSelected = names: lib.filterAttrs (name: _: elem name names) deploymentConfig;
        evalSelected = names: lib.filterAttrs (name: _: elem name names) toplevel;
        evalSelectedDrvPaths = names: lib.mapAttrs (_: v: v.drvPath) (evalSelected names);
        introspect = f: f { inherit lib; pkgs = nixpkgs; nodes = uncheckedNodes; };
      };
    in
    flake-utils-plus.lib.mkFlake {
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

      hosts = lib.genAttrs (builtins.attrNames (builtins.readDir ./hosts)) (n: {
        inherit (LT.hosts."${n}" or (LT.hostDefaults n { })) system;
        modules = modulesFor n;
        specialArgs = specialArgsFor n;
      });

      outputsBuilder = channels:
        let
          pkgs = channels.nixpkgs;
          inherit (pkgs) system;
        in
        {
          apps = lib.mapAttrs
            (n: v: flake-utils.lib.mkApp {
              drv = pkgs.writeShellScriptBin "script" (pkgs.callPackage v {
                inherit inputs;
                LT = import ./helpers { inherit lib inputs pkgs; };
              });
            })
            {
              colmena = ./scripts/colmena.nix;
              check = ./scripts/check.nix;
              dnscontrol = ./scripts/dnscontrol.nix;
              gcore = ./scripts/gcore;
              nvfetcher = ./scripts/nvfetcher.nix;
              update = ./scripts/update.nix;
            };
        };

      colmenaHive = mkColmenaHive
        { allowApplyAll = false; }
        (lib.filterAttrs (n: v: !lib.hasPrefix "_" n) self.nixosConfigurations);

      nixosCD = self.nixosConfigurations._nixos-cd.config.system.build.isoImage;
    };
}
