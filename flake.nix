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
    composer2nix = {
      url = "github:svanderburg/composer2nix";
      flake = false;
    };
    dwarffs = {
      url = "github:edolstra/dwarffs";
      inputs.nix.follows = "nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix = {
      url = "github:NixOS/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
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
    nur.url = "github:nix-community/NUR";
    nur-xddxdd = {
      # url = "/home/lantian/Projects/nur-packages";
      url = "github:xddxdd/nur-packages";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      # url = "/home/lantian/Projects/nixos-secrets";
      url = "git+ssh://git@github.com/xddxdd/nixos-secrets";
      flake = false;
    };
    srvos = {
      url = "github:numtide/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    flake-utils,
    flake-utils-plus,
    ...
  } @ inputs: let
    inherit (inputs.nixpkgs) lib;
    LT = import ./helpers {
      inherit lib inputs self;
      inherit (self) nixosConfigurations;
    };
    specialArgsFor = n: {
      inherit inputs;
      LT = import ./helpers {
        inherit lib inputs self;
        inherit (self) nixosConfigurations;
        inherit (self.nixosConfigurations."${n}") config pkgs;
      };
    };

    inherit (LT) ls;

    modulesFor = n: [
      ({
        config,
        pkgs,
        ...
      }: {
        home-manager.extraSpecialArgs = specialArgsFor n;
        nixpkgs = {
          overlays =
            [
              inputs.colmena.overlay
              inputs.nil.overlays.nil
              inputs.nix-alien.overlay
              inputs.nixos-cn.overlay
              inputs.nur.overlay
            ]
            ++ (import ./overlays {inherit inputs;});
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
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.srvos.nixosModules.mixins-trusted-nix-caches
      (./hosts + "/${n}/configuration.nix")
    ];
  in
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;
      supportedSystems = flake-utils.lib.allSystems;
      channels.nixpkgs = {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-19.0.7"
            "openssh-with-hpn-9.2p1"
            "python-2.7.18.6"
          ];
          # contentAddressedByDefault = true;
        };
        input = inputs.nixpkgs;
        patches = ls ./patches/nixpkgs;
      };

      hosts = lib.genAttrs (builtins.attrNames (builtins.readDir ./hosts)) (n: {
        inherit (LT.hosts."${n}") system;
        modules = modulesFor n;
        specialArgs = specialArgsFor n;
      });

      outputsBuilder = channels: let
        pkgs = channels.nixpkgs;
      in {
        apps =
          lib.mapAttrs
          (n: v:
            flake-utils.lib.mkApp {
              drv = pkgs.writeShellScriptBin "script" (pkgs.callPackage v {
                inherit inputs;
                LT = import ./helpers {inherit lib inputs pkgs;};
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

        formatter = pkgs.alejandra;
      };

      # Export for nixos-secrets
      inherit lib LT;
      exportPkgs = self.pkgs;

      ipv4List = builtins.concatStringsSep "\n" (lib.filter (v: v != "") (lib.mapAttrsToList (k: v: v.public.IPv4) LT.hosts));
      ipv6List = builtins.concatStringsSep "\n" (lib.filter (v: v != "") (lib.mapAttrsToList (k: v: v.public.IPv6) LT.hosts));

      colmenaHive =
        LT.mkColmenaHive
        {allowApplyAll = false;}
        (lib.filterAttrs (n: v: !lib.hasPrefix "_" n) self.nixosConfigurations);
    };
}
