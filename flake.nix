{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    # Common libraries
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-22-05.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-22-11.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-23-05.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };

    attic = {
      url = "github:zhaofengli/attic";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-23-05";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.home-manager.follows = "home-manager";
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
      inputs.stable.follows = "nixpkgs-23-05";
    };
    composer2nix = {
      url = "github:svanderburg/composer2nix";
      flake = false;
    };
    dwarffs = {
      url = "github:edolstra/dwarffs";
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
    impermanence.url = "github:nix-community/impermanence";
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-math = {
      url = "github:xddxdd/nix-math";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-utils-plus.follows = "flake-utils-plus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    nur-xddxdd = {
      # url = "/home/lantian/Projects/nur-packages";
      url = "github:xddxdd/nur-packages";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-utils-plus.follows = "flake-utils-plus";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvfetcher.follows = "nvfetcher";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    secrets = {
      # url = "/home/lantian/Projects/nixos-secrets";
      url = "github:xddxdd/nixos-secrets";
      flake = false;
    };
    srvos = {
      url = "github:numtide/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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

    overlays =
      [
        inputs.agenix.overlays.default
        inputs.colmena.overlay
        inputs.nil.overlays.nil
        inputs.nix-alien.overlay
        inputs.nur.overlay
        inputs.nur-xddxdd.overlay
        inputs.nvfetcher.overlays.default
      ]
      ++ (import ./overlays {inherit inputs;});

    modulesFor = n: [
      ({
        config,
        pkgs,
        ...
      }: {
        home-manager.extraSpecialArgs = specialArgsFor n;
        networking.hostName = lib.mkForce (lib.removePrefix "_" n);
        system.stateVersion = LT.constants.stateVersion;
      })
      (inputs.attic + "/nixos/atticd.nix")
      inputs.agenix.nixosModules.age
      inputs.colmena.nixosModules.deploymentOptions
      inputs.impermanence.nixosModules.impermanence
      inputs.home-manager.nixosModules.home-manager
      inputs.nur-xddxdd.nixosModules.openssl-oqs-provider
      inputs.nur-xddxdd.nixosModules.qemu-user-static-binfmt
      (inputs.srvos + "/nixos/common/networking.nix")
      (inputs.srvos + "/nixos/common/upgrade-diff.nix")
      (inputs.srvos + "/nixos/common/well-known-hosts.nix")
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.srvos.nixosModules.mixins-trusted-nix-caches
      (./hosts + "/${n}/configuration.nix")
    ];
  in
    flake-utils-plus.lib.mkFlake {
      inherit self;
      inputs = {
        inherit (inputs) nixpkgs;
      };
      supportedSystems = flake-utils.lib.allSystems;
      channels.nixpkgs = {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-19.1.9"
            "openssl-1.1.1w"
            "python-2.7.18.7"
          ];
          # contentAddressedByDefault = true;
        };
        input = inputs.nixpkgs;
        patches = ls ./patches/nixpkgs;
        overlaysBuilder = channels: overlays;
      };

      hosts = lib.genAttrs (builtins.attrNames (builtins.readDir ./hosts)) (n: {
        inherit (LT.hosts."${n}") system;
        modules = modulesFor n;
        specialArgs = specialArgsFor n;
      });

      outputsBuilder = channels: let
        pkgs = channels.nixpkgs;

        extraArgs = {
          inherit inputs;
          LT = import ./helpers {inherit lib inputs pkgs;};
          packages = self.packages."${pkgs.system}";
        };
        pkg = v: args: pkgs.callPackage v (extraArgs // args);

        commands =
          lib.mapAttrs
          (n: v: pkgs.writeShellScriptBin n (pkg v {}))
          {
            colmena = ./scripts/colmena.nix;
            check = ./scripts/check.nix;
            dnscontrol = ./scripts/dnscontrol.nix;
            gcore = ./scripts/gcore;
            nvfetcher = ./scripts/nvfetcher.nix;
            secrets = ./scripts/secrets.nix;
            terraform = ./scripts/terraform.nix;
            update = ./scripts/update.nix;
          };
      in rec {
        apps = lib.mapAttrs (n: v: flake-utils.lib.mkApp {drv = v;}) commands;

        devShells.default = pkgs.mkShell {
          buildInputs = lib.mapAttrsToList (n: v: v) commands;
        };

        formatter = pkgs.alejandra;

        packagesList = lib.flatten (builtins.map (overlay: builtins.attrNames (overlay pkgs pkgs)) overlays);
        packages =
          (lib.genAttrs packagesList (n: pkgs."${n}"))
          // rec {
            # DNSControl
            dnscontrol-config = pkgs.writeText "dnsconfig.js" (pkg ./dns {});

            # Terraform
            xddxdd-uptimerobot = pkgs.callPackage terraform/providers/xddxdd-uptimerobot.nix {};

            terraform-config = inputs.terranix.lib.terranixConfiguration {
              inherit (pkgs) system;
              modules = [./terraform];
              inherit extraArgs;
            };
            terraform-with-plugins = pkgs.terraform.withPlugins (plugins: [
              xddxdd-uptimerobot
            ]);
          };
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
