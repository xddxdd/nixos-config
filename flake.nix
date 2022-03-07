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
      inputs.nix.follows = "nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix = {
      url = "github:NixOS/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cn = {
      url = "github:nixos-cn/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nur.url = "github:nix-community/NUR";
    nur-xddxdd = {
      url = "github:xddxdd/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      lib = nixpkgs.lib;
      LT = import ./helpers { inherit lib; };

      overlays = [
        inputs.colmena.overlay
        inputs.nix-alien.overlay
        inputs.nur-xddxdd.overlay
        inputs.nvfetcher.overlay
        (import ./overlay.nix { inherit inputs nixpkgs; })
      ];

      modulesFor = n:
        let
          inherit (LT.hosts."${n}") system role;
        in
        [
          ({
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            networking.hostName = n;
            nixpkgs = { inherit system overlays; };
            system.stateVersion = LT.constants.stateVersion;
          })
          inputs.agenix.nixosModules.age
          inputs.dwarffs.nixosModules.dwarffs
          ({ lib, config, ... }: inputs.flake-utils-plus.nixosModules.autoGenFromInputs { inherit lib config inputs; })
          inputs.home-manager.nixosModules.home-manager
          inputs.impermanence.nixosModules.impermanence
          inputs.nixos-cn.nixosModules.nixos-cn
          (./hosts + "/${n}/configuration.nix")
        ] ++ lib.optionals (system == "x86_64-linux") [
          inputs.nix-ld.nixosModules.nix-ld
        ] ++ lib.optionals (role == LT.roles.client) [
          inputs.nur-xddxdd.nixosModules.svpWithNvidia
        ];

      eachSystem = flake-utils.lib.eachSystemMap flake-utils.lib.allSystems;
    in
    rec {
      nixosConfigurations = lib.mapAttrs
        (n: { system, ... }: lib.nixosSystem {
          inherit system;
          modules = modulesFor n;
        })
        LT.hosts;

      packages = eachSystem (system: {
        homeConfigurations =
          let
            cfg = attrs: inputs.home-manager.lib.homeManagerConfiguration ({
              inherit system;
              inherit (LT.constants) stateVersion;
              configuration = { config, pkgs, lib, ... }: {
                nixpkgs.overlays = overlays;
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
          inherit inputs overlays system;
          inherit (LT.constants) stateVersion;
        };
      });

      colmena = {
        meta.nixpkgs = { inherit lib; };
        meta.nodeNixpkgs = lib.mapAttrs (n: v: import nixpkgs { inherit (v) system; }) LT.nixosHosts;
      } // (lib.mapAttrs
        (n: { hostname, sshPort, role, ... }: {
          deployment = {
            allowLocalDeployment = role == LT.roles.client;
            targetHost = hostname;
            targetPort = sshPort;
            targetUser = "root";
          };

          imports = modulesFor n;
        })
        LT.nixosHosts);

      apps = eachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          dnsRecords = pkgs.writeText "dnsconfig.js" (import ./dns { inherit pkgs; inherit (LT) hosts; });
        in
        {
          dnscontrol = pkgs.writeShellScriptBin "dnscontrol" ''
            CURR_DIR=$(pwd)

            TEMP_DIR=$(mktemp -d /tmp/dns.XXXXXXXX)
            cp ${dnsRecords} $TEMP_DIR/dnsconfig.js
            ${pkgs.age}/bin/age \
              -i "$HOME/.ssh/id_ed25519" \
              --decrypt -o "$TEMP_DIR/creds.json" \
              "${inputs.secrets}/dnscontrol.age"
            mkdir -p "$TEMP_DIR/zones"

            cd "$TEMP_DIR"
            ${pkgs.dnscontrol}/bin/dnscontrol $*
            RET=$?
            rm -rf "$CURR_DIR/zones"
            mv "$TEMP_DIR/zones" "$CURR_DIR/zones"

            cd "$CURR_DIR"
            rm -rf "$TEMP_DIR"
            exit $RET
          '';

          nvfetcher = pkgs.writeShellScriptBin "nvfetcher" ''
            ${pkgs.nvfetcher}/bin/nvfetcher -c nvfetcher.toml -o helpers/_sources
          '';
        });
    };
}
