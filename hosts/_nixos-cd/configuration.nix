{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  # Avoid cyclic dependency
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/iso-image.nix
  boot = {
    loader.grub.enable = lib.mkForce false;
    kernelPackages = lib.mkForce pkgs.zfs.latestCompatibleLinuxPackages;
  };

  isoImage.isoName = lib.mkForce "nixos-lantian.iso";
  networking.useDHCP = lib.mkForce true;

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
      inherit (LT.constants.nix) substituters trusted-public-keys;
    };
  };

  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    inputs.nur-xddxdd.nixosModules.qemu-user-static-binfmt

    ../../nixos/common-components/cacert.nix
    ../../nixos/common-components/environment.nix
    ../../nixos/common-components/networking.nix
    ../../nixos/common-components/ssh-harden.nix
    ../../nixos/common-components/users.nix
    ../../nixos/common-components/wireguard-fix.nix
  ];
}
