{ inputs
, overlays
, stateVersion
, ...
}:

let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) lib;
in
(lib.nixosSystem rec {
  system = "x86_64-linux";
  modules = [
    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ({ lib, config, ... }: inputs.flake-utils-plus.nixosModules.autoGenFromInputs { inherit lib config inputs; })
    ({ pkgs, ... }: {
      # Avoid cyclic dependency
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/iso-image.nix
      boot.loader.grub.enable = lib.mkForce false;

      boot.kernelPackages = lib.mkForce pkgs.zfs.latestCompatibleLinuxPackages;
      boot.initrd.includeDefaultModules = lib.mkForce true;

      isoImage.isoName = lib.mkForce "nixos-lantian.iso";

      lantian.enableGUI = true;
      nixpkgs = { inherit system overlays; };
      system.stateVersion = stateVersion;

      imports = [
        ./required-components/boot-params.nix
        ./required-components/environment.nix
        ./required-components/networking.nix
        ./required-components/nix.nix
        ./required-components/qemu-user-static.nix
        ./required-components/ssh-harden.nix
        ./required-components/users.nix
      ];
    })
  ];
}).config.system.build.isoImage
