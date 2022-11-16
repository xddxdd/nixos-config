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
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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
    nixos-openvz = {
      url = "github:zhaofengli/nixos-openvz";
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

      modulesFor = n:
        let
          inherit (LT.hosts."${n}") system role openvz;
        in
        [
          ({ config, ... }: {
            home-manager = {
              backupFileExtension = "bak";
              useGlobalPkgs = true;
              useUserPackages = true;
            };
            nixpkgs.overlays = [
              inputs.colmena.overlay
              inputs.nix-alien.overlay
              inputs.nixos-cn.overlay
              inputs.nil.overlays.nil
              (inputs.nur-xddxdd.overlays.custom
                config.boot.kernelPackages.nvidia_x11)
            ] ++ (import ./overlays { inherit inputs lib; });
            networking.hostName = n;
            system.stateVersion = LT.constants.stateVersion;
          })
          inputs.agenix.nixosModules.age
          inputs.dwarffs.nixosModules.dwarffs
          ({ lib, config, ... }: inputs.flake-utils-plus.nixosModules.autoGenFromInputs { inherit lib config inputs; })
          inputs.impermanence.nixosModules.impermanence
          inputs.home-manager.nixosModules.home-manager
          inputs.nur-xddxdd.nixosModules.qemu-user-static-binfmt
        ] ++ lib.optionals openvz [
          inputs.nixos-openvz.nixosModules.ovz-container
          inputs.nixos-openvz.nixosModules.ovz-installer
        ] ++ [
          (./hosts + "/${n}/configuration.nix")
        ];

      eachSystem = flake-utils.lib.eachSystemMap flake-utils.lib.allSystems;
    in
    rec {
      nixosConfigurations = lib.mapAttrs
        (n: { system, ... }:
          nixpkgs."${system}".nixos {
            imports = modulesFor n;
          })
        LT.hosts;

      openvz = lib.mapAttrs (n: v: v.config.system.build.tarball) nixosConfigurations;

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
      } // (lib.mapAttrs
        (n: { hostname, sshPort, role, manualDeploy, ... }: {
          deployment = {
            allowLocalDeployment = role == LT.roles.client;
            targetHost = hostname;
            targetPort = sshPort;
            targetUser = "root";
            tags = [ role ] ++ (lib.optional (!manualDeploy) "default");
          };

          imports = modulesFor n;
        })
        LT.nixosHosts);

      apps = eachSystem (system:
        let
          pkgs = nixpkgs."${system}";
          dnsRecords = pkgs.writeText "dnsconfig.js" (import ./dns { inherit pkgs lib inputs; });

          mkApp = script: {
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "script" script);
          };

          dnscontrol = pkgs.buildGoModule rec {
            pname = "dnscontrol";
            version = "3af61f2cd4ad9929ed21cadac7787edc56e67018";

            src = pkgs.fetchFromGitHub {
              owner = "xddxdd";
              repo = "dnscontrol";
              rev = version;
              sha256 = "sha256-Fzb383JfQ2VaIJR0Un3PQ35z7Bjh0aTyHMCZxEQ6lqw=";
            };

            vendorSha256 = "sha256-f6O5JcaDVtpp9RRzAYVqefeVpw0sHRSbvLSry79mvMI=";

            ldflags = [ "-s" "-w" ];

            preCheck = ''
              # requires network
              rm pkg/spflib/flatten_test.go pkg/spflib/parse_test.go
            '';
          };
        in
        {
          colmena = mkApp ''
            ACTION=$1; shift;
            if [ "$ACTION" = "apply" ] || [ "$ACTION" = "build" ]; then
              colmena $ACTION --keep-result $*
              exit $?
            else
              colmena $ACTION $*
              exit $?
            fi
          '';

          check = mkApp ''
            ${pkgs.statix}/bin/statix check . -i _sources
          '';

          dnscontrol = mkApp ''
            CURR_DIR=$(pwd)

            TEMP_DIR=$(mktemp -d /tmp/dns.XXXXXXXX)
            cp ${dnsRecords} $TEMP_DIR/dnsconfig.js
            ${pkgs.age}/bin/age \
              -i "$HOME/.ssh/id_ed25519" \
              --decrypt -o "$TEMP_DIR/creds.json" \
              "${inputs.secrets}/dnscontrol.age"
            mkdir -p "$TEMP_DIR/zones"

            cd "$TEMP_DIR"
            ${dnscontrol}/bin/dnscontrol $*
            RET=$?
            rm -rf "$CURR_DIR/zones"
            mv "$TEMP_DIR/zones" "$CURR_DIR/zones"

            cd "$CURR_DIR"
            rm -rf "$TEMP_DIR"
            exit $RET
          '';

          nvfetcher = mkApp ''
            ${pkgs.nvfetcher}/bin/nvfetcher -c nvfetcher.toml -o helpers/_sources
          '';

          update = mkApp ''
            nix flake update
            ${pkgs.nvfetcher}/bin/nvfetcher -c nvfetcher.toml -o helpers/_sources
          '';
        });
    };
}
