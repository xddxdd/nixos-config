{
  self,
  lib,
  inputs,
  ...
}:
let
  LT = import ../helpers {
    inherit lib inputs self;
  };

  pkgsNameFor = n: if LT.hosts."${n}".hasTag LT.tags.cuda then "pkgsWithCuda" else "pkgs";

  specialArgsFor = n: {
    inherit self inputs;
    LT = import ../helpers {
      inherit lib inputs self;
      inherit (self.nixosConfigurations."${n}") config pkgs;
    };
  };

  modulesFor =
    n:
    let
      inherit (LT.hosts."${n}") system;
    in
    [
      (_: {
        home-manager.extraSpecialArgs = specialArgsFor n;
        networking.hostName = lib.mkForce (lib.removePrefix "_" n);
        system.stateVersion = LT.constants.stateVersion;

        # Force inherit nixpkgs
        _module.args.pkgs = lib.mkForce (patchedPkgsFor system (pkgsNameFor n));
      })

      # keep-sorted start
      (inputs.srvos + "/shared/common/update-diff.nix")
      (inputs.srvos + "/shared/common/well-known-hosts.nix")
      inputs.agenix.nixosModules.age
      inputs.angrr.nixosModules.angrr
      inputs.colmena.nixosModules.deploymentOptions
      inputs.home-manager.nixosModules.home-manager
      inputs.nix-cache-proxy.nixosModules.nix-cache-proxy
      inputs.nix-gaming.nixosModules.platformOptimizations
      inputs.nur-xddxdd.nixosModules.nix-cache-attic
      inputs.nur-xddxdd.nixosModules.nix-cache-garnix
      inputs.nur-xddxdd.nixosModules.openssl-conf
      inputs.nur-xddxdd.nixosModules.openssl-gost-engine
      inputs.nur-xddxdd.nixosModules.openssl-oqs-provider
      inputs.nur-xddxdd.nixosModules.qemu-user-static-binfmt
      inputs.nur-xddxdd.nixosModules.wireguard-remove-lingering-links
      inputs.preservation.nixosModules.preservation
      inputs.proxmox-nixos.nixosModules.proxmox-ve
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.srvos.nixosModules.mixins-trusted-nix-caches
      inputs.stylix.nixosModules.stylix
      # keep-sorted end

      (../hosts + "/${n}/configuration.nix")
    ];

  patchedPkgsFor = system: pkgsName: self.allSystems."${system}"._module.args."${pkgsName}";
  patchedNixpkgsFor = system: pkgsName: self.packages."${system}"."${pkgsName}-patched";
in
{
  flake = {
    nixosConfigurations = lib.mapAttrs (
      n: _:
      let
        inherit (LT.hosts."${n}") system;
        pkgs = patchedPkgsFor system (pkgsNameFor n);
        nixpkgs = patchedNixpkgsFor system (pkgsNameFor n);
      in
      (import (nixpkgs + "/nixos/lib/eval-config.nix")) {
        inherit system pkgs;
        modules = modulesFor n;
        specialArgs = specialArgsFor n;
      }
    ) (builtins.readDir ../hosts);
  };
}
