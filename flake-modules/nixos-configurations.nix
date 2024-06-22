{
  self,
  lib,
  inputs,
  ...
}:
let
  LT = import ../helpers {
    inherit lib inputs self;
    inherit (self) nixosConfigurations;
  };

  specialArgsFor = n: {
    inherit inputs;
    LT = import ../helpers {
      inherit lib inputs self;
      inherit (self) nixosConfigurations;
      inherit (self.nixosConfigurations."${n}") config pkgs;
    };
  };

  modulesFor =
    n:
    let
      inherit (LT.hosts."${n}") system;
    in
    [
      (
        { pkgs, ... }:
        {
          home-manager.extraSpecialArgs = specialArgsFor n;
          networking.hostName = lib.mkForce (lib.removePrefix "_" n);
          system.stateVersion = LT.constants.stateVersion;

          # Force inherit nixpkgs
          _module.args.pkgs = lib.mkForce (patchedPkgsFor system);
        }
      )
      (inputs.attic + "/nixos/atticd.nix")
      inputs.agenix.nixosModules.age
      inputs.colmena.nixosModules.deploymentOptions
      inputs.impermanence.nixosModules.impermanence
      inputs.home-manager.nixosModules.home-manager
      inputs.nix-gaming.nixosModules.pipewireLowLatency
      inputs.nix-gaming.nixosModules.platformOptimizations
      inputs.nur-xddxdd.nixosModules.nix-cache-attic
      inputs.nur-xddxdd.nixosModules.nix-cache-cachix
      inputs.nur-xddxdd.nixosModules.nix-cache-garnix
      inputs.nur-xddxdd.nixosModules.openssl-oqs-provider
      inputs.nur-xddxdd.nixosModules.qemu-user-static-binfmt
      inputs.nur-xddxdd.nixosModules.wireguard-remove-lingering-links
      (inputs.srvos + "/nixos/common/networking.nix")
      (inputs.srvos + "/nixos/common/upgrade-diff.nix")
      (inputs.srvos + "/nixos/common/well-known-hosts.nix")
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.srvos.nixosModules.mixins-trusted-nix-caches
      (../hosts + "/${n}/configuration.nix")
    ];

  patchedPkgsFor = system: self.allSystems."${system}"._module.args.pkgs;
  patchedNixpkgsFor = system: self.packages."${system}".nixpkgs-patched;
in
{
  flake = {
    nixosConfigurations = lib.genAttrs (builtins.attrNames (builtins.readDir ../hosts)) (
      n:
      let
        inherit (LT.hosts."${n}") system;
        pkgs = patchedPkgsFor system;
        nixpkgs = patchedNixpkgsFor system;
      in
      (import (nixpkgs + "/nixos/lib/eval-config.nix")) {
        inherit system pkgs;
        modules = modulesFor n;
        specialArgs = specialArgsFor n;
      }
    );
  };
}
