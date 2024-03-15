{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    # Common libraries
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-22-05.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-22-11.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-23-05.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-23-11.url = "github:NixOS/nixpkgs/nixos-23.11";
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
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    nur-xddxdd = {
      # url = "/home/lantian/Projects/nur-packages";
      url = "github:xddxdd/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
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
        ./flake-modules/nixos-configurations.nix
        ./flake-modules/nixpkgs-options.nix
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
              tag: builtins.attrNames (lib.filterAttrs (n: v: builtins.elem tag (LT.tagsForHost v)) LT.hosts);
          in
          {
            all = buildCommandFor (builtins.attrNames LT.hosts);
            x86_64-linux = buildCommandFor (hostsWithTag "x86_64-linux");
          };

        ipv4List = builtins.concatStringsSep "\n" (
          lib.filter (v: v != "") (lib.mapAttrsToList (k: v: v.public.IPv4) LT.hosts)
        );
        ipv6List = builtins.concatStringsSep "\n" (
          lib.filter (v: v != "") (lib.mapAttrsToList (k: v: v.public.IPv6) LT.hosts)
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
          formatter = pkgs.nixfmt-rfc-style;

          packages = rec {
            # DNSControl
            dnscontrol-config = pkgs.writeText "dnsconfig.js" (
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
              }).config._dnsconfig_js
            );

            # Terraform
            xddxdd-uptimerobot = pkgs.callPackage terraform/providers/xddxdd-uptimerobot.nix { };

            terraform-config = inputs.terranix.lib.terranixConfiguration {
              inherit (pkgs) system;
              modules = [ ./terraform ];
              inherit extraArgs;
            };
            terraform-with-plugins = pkgs.terraform.withPlugins (plugins: [ xddxdd-uptimerobot ]);
          };
        };
    };
}
