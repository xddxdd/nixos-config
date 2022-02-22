{ inputs
, system
, stateVersion
, ...
}:

let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) lib;
in
(lib.nixosSystem rec {
  inherit system;
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
      networking.useDHCP = lib.mkForce true;
      system.stateVersion = stateVersion;

      imports =
        let
          ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
        in
        builtins.filter (v: (builtins.match "(.*)(impermanence|qemu-user-static)\\.nix" (builtins.toString v)) == null) (ls ./common-components);
    })
  ];
}).config.system.build.isoImage
