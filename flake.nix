{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vscode-server = {
      url = "github:iosmanthus/nixos-vscode-server/add-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = github:nix-community/NUR;
    nur-xddxdd = {
      url = github:xddxdd/nur-packages;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hath-nix.url = github:poscat0x04/hath-nix;
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, nur, hath-nix, ... }@inputs:
    let
      lib = nixpkgs.lib;
      hosts = import ./hosts.nix;

      # hostsList = [ "soyoustart" ];
      hostsList = builtins.filter (k: hosts."${k}".deploy or true) (lib.mapAttrsToList (n: v: n) hosts);

      stateVersion = "21.05";

      overlays = [
        (final: prev: {
          flakeInputs = inputs;
          nur = import nur {
            nurpkgs = prev;
            pkgs = prev;
            repoOverrides = { xddxdd = import inputs.nur-xddxdd { pkgs = prev; }; };
          };
          rage = prev.stdenv.mkDerivation rec {
            name = "rage";
            version = prev.age.version;

            phases = [ "installPhase" ];
            installPhase = ''
              mkdir -p $out/bin
              ln -s ${prev.age}/bin/age $out/bin/rage
              ln -s ${prev.age}/bin/age-keygen $out/bin/rage-keygen
            '';
          };
        })
        hath-nix.overlay
      ];

      systemFor = n: hosts."${n}".system or "x86_64-linux";
      hostnameFor = n: hosts."${n}".hostname or "${n}.lantian.pub";
      sshPortFor = n: hosts."${n}".sshPort or 2222;

      modulesFor = n: [
        ({
          networking.hostName = n;
          nixpkgs.overlays = overlays;
          nixpkgs.system = systemFor n;
          system.stateVersion = stateVersion;
        })
        inputs.agenix.nixosModules.age
        inputs.impermanence.nixosModules.impermanence
        inputs.nixos-vscode-server.nixosModules.system
        ./common/common.nix
        (import ./common/home-manager.nix { inherit inputs overlays stateVersion; })
        (./hosts + "/${n}/configuration.nix")
      ];
    in
    {
      nixosConfigurations = lib.genAttrs hostsList
        (n: lib.nixosSystem {
          system = systemFor n;
          modules = modulesFor n;
        });

      homeConfigurations = {
        lantian = inputs.home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-linux";
          username = "lantian";
          homeDirectory = "/home/${username}";
          inherit stateVersion;
          # FIXME: Support remote deploy to GUI systems
          configuration = import ./home/user-gui.nix { inherit inputs overlays stateVersion; };
        };
        root = inputs.home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-linux";
          username = "root";
          homeDirectory = "/root";
          inherit stateVersion;
          # FIXME: Support remote deploy to GUI systems
          configuration = import ./home/user-gui.nix { inherit inputs overlays stateVersion; };
        };
      };
      lantian = self.homeConfigurations.lantian.activationPackage;
      root = self.homeConfigurations.root.activationPackage;

      colmena = {
        meta.nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
      } // (lib.genAttrs hostsList
        (n: {
          deployment = {
            targetHost = hostnameFor n;
            targetPort = sshPortFor n;
            targetUser = "root";
          };

          imports = modulesFor n;
        }));

      dnsRecords = import ./dns/toplevel.nix rec {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        dns = import ./common/components/dns/default.nix { inherit pkgs; };
      };
    };
}
