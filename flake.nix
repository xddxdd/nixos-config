{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    # Common libraries
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-24-05.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:oluceps/agenix/with-sysuser";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    betterfox-nix = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cities-json = {
      url = "github:lutangar/cities.json";
      flake = false;
    };
    colmena = {
      url = "github:zhaofengli/colmena/direct-flake-eval";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.stable.follows = "nixpkgs";
    };
    composer2nix = {
      url = "github:svanderburg/composer2nix";
      flake = false;
    };
    dwarffs.url = "github:edolstra/dwarffs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nur.url = "github:nix-community/NUR";
    nur-xddxdd = {
      # url = "/home/lantian/Projects/nur-packages";
      url = "github:xddxdd/nur-packages";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nix-index-database.follows = "nix-index-database";
      inputs.nvfetcher.follows = "nvfetcher";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    preservation.url = "github:WilliButz/preservation";
    proxmox-nixos = {
      url = "github:xddxdd/proxmox-nixos";
      inputs.utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    secrets = {
      # url = "/home/lantian/Projects/nixos-secrets";
      url = "github:xddxdd/nixos-secrets";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, flake-parts, ... }@inputs:
    let
      inherit (inputs.nixpkgs) lib;
      LT = import ./helpers {
        inherit lib inputs self;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/commands
        ./flake-modules/nixd.nix
        ./flake-modules/nixos-configurations.nix
        inputs.nur-xddxdd.flakeModules.auto-colmena-hive-v0_20241006
        inputs.nur-xddxdd.flakeModules.commands
        inputs.nur-xddxdd.flakeModules.lantian-pre-commit-hooks
        inputs.nur-xddxdd.flakeModules.lantian-treefmt
        inputs.nur-xddxdd.flakeModules.nixpkgs-options
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

      nixpkgs-options =
        let
          permittedInsecurePackages = [
            "aspnetcore-runtime-6.0.36"
            "aspnetcore-runtime-wrapped-6.0.36"
            "dotnet-sdk-6.0.428"
            "dotnet-sdk-wrapped-6.0.428"
            "fluffychat-linux-1.23.0"
            "olm-3.2.16"
          ];
          overlays =
            let
              rpi_dt_ao_overlay = _final: prev: {
                deviceTree = prev.deviceTree // {
                  applyOverlays = _final.callPackage (
                    inputs.nixos-hardware + "/raspberry-pi/4/apply-overlays-dtmerge.nix"
                  ) { };
                };
              };
            in
            [
              inputs.aagl.overlays.default
              inputs.agenix.overlays.default
              inputs.colmena.overlay
              inputs.nil.overlays.nil
              inputs.nix-alien.overlays.default
              inputs.nixd.overlays.default
              inputs.nur.overlays.default
              inputs.nur-xddxdd.overlays.inSubTree-pinnedNixpkgsWithCuda
              inputs.nvfetcher.overlays.default
              inputs.proxmox-nixos.overlays.x86_64-linux
              inputs.secrets.overlays.default
              rpi_dt_ao_overlay
            ]
            ++ (import ./overlays { inherit inputs; });
        in
        {
          pkgs = {
            sourceInput = inputs.nixpkgs;
            patches = LT.ls ./patches/nixpkgs;
            inherit permittedInsecurePackages overlays;
          };
          pkgs-stable = {
            sourceInput = inputs.nixpkgs-stable;
            patches = LT.ls ./patches/nixpkgs-stable;
            inherit permittedInsecurePackages overlays;
          };
        };

      perSystem =
        { config, pkgs, ... }:
        let
          LT = import ./helpers {
            inherit lib inputs self;
            inherit pkgs;
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
          };
        };
    };
}
