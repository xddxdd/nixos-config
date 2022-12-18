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

  outputs = { self, flake-utils, flake-utils-plus, ... }@inputs:
    let
      ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));

      inherit (inputs.nixpkgs) lib;
      LT = import ./helpers { inherit lib inputs; };
      specialArgs = { inherit inputs; };

      modulesFor = n: [
        ({ config, ... }: {
          deployment =
            let
              inherit (LT.hosts."${n}" or LT.hostDefaults) hostname sshPort role manualDeploy;
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
        inputs.nur-xddxdd.nixosModules.qemu-user-static-binfmt
        (./hosts + "/${n}/configuration.nix")
      ];
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
        inherit specialArgs;
        modules = modulesFor n;
        system = LT.hosts."${n}".system or "x86_64-linux";
      });

      outputsBuilder = channels:
        let
          pkgs = channels.nixpkgs;
          inherit (pkgs) system;

          mkApp = path: {
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "script" (pkgs.callPackage path specialArgs));
          };
        in
        {
          apps = {
            colmena = mkApp ./scripts/colmena.nix;
            check = mkApp ./scripts/check.nix;
            dnscontrol = mkApp ./scripts/dnscontrol.nix;
            gcore = mkApp ./scripts/gcore;
            nvfetcher = mkApp ./scripts/nvfetcher.nix;
            update = mkApp ./scripts/update.nix;
          };
        };

      colmenaHive = LT.flake.mkColmenaHive
        { allowApplyAll = false; }
        (lib.filterAttrs (n: v: !lib.hasPrefix "_" n) self.nixosConfigurations);

      nixosCD = self.nixosConfigurations._nixos-cd.config.system.build.isoImage;
    };
}
