{ inputs
, nixpkgs
, lib
, system
, constants
, ...
}:

(nixpkgs."${system}".nixos rec {
  imports = [
    inputs.agenix.nixosModules.age
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ({ lib, config, ... }: inputs.flake-utils-plus.nixosModules.autoGenFromInputs { inherit lib config inputs; })
    ({ pkgs, lib, ... }: {
      # Avoid cyclic dependency
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/iso-image.nix
      boot.initrd.includeDefaultModules = lib.mkForce true;
      boot.kernelPackages = lib.mkForce pkgs.zfs.latestCompatibleLinuxPackages;
      boot.loader.grub.enable = lib.mkForce false;

      isoImage.isoName = lib.mkForce "nixos-lantian.iso";
      networking.useDHCP = lib.mkForce true;
      system.stateVersion = constants.stateVersion;

      environment.etc."nixos-config".source = inputs.self;

      nix = {
        package = pkgs.nixUnstable;
        extraOptions = ''
          experimental-features = nix-command flakes ca-derivations
        '';
        generateNixPathFromInputs = true;
        generateRegistryFromInputs = true;
        linkInputs = true;
        settings = {
          auto-optimise-store = true;
          inherit (constants.nix) substituters trusted-public-keys;
        };
      };

      imports = [
        ./common-components/cacert.nix
        ./common-components/environment.nix
        ./common-components/networking.nix
        ./common-components/no-docs.nix
        ./common-components/qemu-user-static.nix
        ./common-components/ssh-harden.nix
        ./common-components/users.nix
        ./common-components/wireguard-fix.nix
      ];
    })
  ];
}).config.system.build.isoImage
