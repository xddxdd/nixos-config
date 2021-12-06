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
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, nur, deploy-rs, hath-nix, ... }@inputs:
    let
      lib = nixpkgs.lib;
      hosts = import ./hosts.nix;

      # hostsList = [ "soyoustart" ];
      hostsList = lib.mapAttrsToList (n: v: n) hosts;

      stateVersion = "21.05";

      overlays = [
        nur.overlay
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

      systemFor = n: if (builtins.hasAttr "system" hosts."${n}") then hosts."${n}".system else "x86_64-linux";
      hostnameFor = n: if (builtins.hasAttr "hostname" hosts."${n}") then hosts."${n}".hostname else "${n}.lantian.pub";
      sshPortFor = n: if (builtins.hasAttr "sshPort" hosts."${n}") then hosts."${n}".sshPort else 2222;

      modulesFor = n: [
        ({
          networking.hostName = n;
          nixpkgs.overlays = overlays;
          nixpkgs.system = systemFor n;
          system.stateVersion = stateVersion;
        })
        inputs.agenix.nixosModules.age
        inputs.impermanence.nixosModules.impermanence
        ./common/common.nix
        (import ./common/home-manager.nix { inherit inputs stateVersion; })
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
          configuration = import ./home/user.nix { inherit inputs stateVersion; };
        };
      };
      lantian = self.homeConfigurations.lantian.activationPackage;

      deploy = {
        sshUser = "root";
        user = "root";
        autoRollback = false;
        magicRollback = false;

        nodes = lib.genAttrs hostsList
          (n:
            let
              nixosNextboot = base: deploy-rs.lib."${systemFor n}".activate.custom base.config.system.build.toplevel ''
                # work around https://github.com/NixOS/nixpkgs/issues/73404
                cd /tmp
                $PROFILE/bin/switch-to-configuration boot
              '';
            in
            {
              hostname = hostnameFor n;
              profiles.system = {
                # path = nixosNextboot self.nixosConfigurations."${n}";
                path = deploy-rs.lib."${systemFor n}".activate.nixos self.nixosConfigurations."${n}";
                sshOpts = [ "-p" (builtins.toString (sshPortFor n)) ];
              };
            });
      };

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
