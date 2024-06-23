{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    # Common libraries
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";

    attic = {
      url = "github:zhaofengli/attic";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
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
      inputs.stable.follows = "nixpkgs";
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
    impermanence.url = "github:nix-community/impermanence";
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-math = {
      url = "github:xddxdd/nix-math";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixd = {
      url = "github:nix-community/nixd";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    nur-xddxdd = {
      # url = "/home/lantian/Projects/nur-packages";
      url = "github:xddxdd/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nix-index-database.follows = "nix-index-database";
      inputs.nvfetcher.follows = "nvfetcher";
      inputs.pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      # url = "/home/lantian/Projects/nixos-secrets";
      url = "github:xddxdd/nixos-secrets";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, flake-parts, ... }@inputs:
    let
      inherit (inputs.nixpkgs) lib;
      LT = import ./helpers {
        inherit lib inputs self;
        inherit (self) nixosConfigurations;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/commands.nix
        ./flake-modules/nixd.nix
        ./flake-modules/nixos-configurations.nix
        ./flake-modules/nixpkgs-options.nix
        ./flake-modules/pre-commit-hooks.nix
        ./flake-modules/treefmt.nix
        inputs.nur-xddxdd.flakeModules.auto-colmena-hive
      ];

      debug = true;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = rec {
        # Export for nixos-secrets
        inherit lib LT;
        exportPkgs = self.pkgs;

        buildCommands =
          let
            buildCommandFor = lib.concatMapStringsSep " " (
              host: ".#nixosConfigurations.${host}.config.system.build.toplevel"
            );
            hostsWithTag =
              tag: builtins.attrNames (lib.filterAttrs (_n: v: builtins.elem tag (LT.tagsForHost v)) LT.hosts);
          in
          {
            all = buildCommandFor (builtins.attrNames LT.hosts);
            x86_64-linux = buildCommandFor (hostsWithTag "x86_64-linux");
          };

        ipv4List = builtins.concatStringsSep "\n" (
          lib.filter (v: v != "") (lib.mapAttrsToList (_k: v: v.public.IPv4) LT.hosts)
        );
        ipv6List = builtins.concatStringsSep "\n" (
          lib.filter (v: v != "") (lib.mapAttrsToList (_k: v: v.public.IPv6) LT.hosts)
        );
      };

      perSystem =
        {
          config,
          system,
          pkgs,
          ...
        }:
        let
          LT = import ./helpers {
            inherit lib inputs self;
            inherit (self) nixosConfigurations;
            inherit pkgs;
          };

          extraArgs = {
            inherit inputs;
            LT = import ./helpers { inherit lib inputs pkgs; };
            packages = self.packages."${pkgs.system}";
          };
        in
        {
          packages = rec {
            # DNSControl
            dnscontrol-config =
              pkgs.writeText "dnsconfig.js"
                (lib.evalModules {
                  modules = [ ./dns/default.nix ];
                  specialArgs = {
                    inherit
                      pkgs
                      lib
                      LT
                      inputs
                      ;
                  };
                }).config._dnsconfig_js;

            # Terraform
            xddxdd-uptimerobot = pkgs.callPackage terraform/providers/xddxdd-uptimerobot.nix { };

            terraform-config = inputs.terranix.lib.terranixConfiguration {
              inherit (pkgs) system;
              modules = [ ./terraform ];
              inherit extraArgs;
            };
            terraform-with-plugins = pkgs.terraform.withPlugins (_plugins: [ xddxdd-uptimerobot ]);
          };
        };
    };
}
