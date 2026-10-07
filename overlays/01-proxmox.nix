{ inputs, ... }:
final: prev:
let
  mv = inputs.nixpkgs-multiverse.multiverse.${final.stdenv.hostPlatform.system};

  # nixpkgs builds libxcrypt with `--enable-hashes=strong`, which omits
  # sha256crypt that PVE's password hashing needs.
  # It is also linked into pve-qemu, whose stdenv comes from the pinned
  # multiverse qemu (glibc 2.42), so build it against the 26.05 nixpkgs as
  # well; a libxcrypt built with the current glibc references symbols that
  # stdenv does not provide.
  libxcrypt = (mv.at "26.05").libxcrypt.overrideAttrs (old: {
    configureFlags = map (
      flag: if prev.lib.hasPrefix "--enable-hashes=" flag then "${flag},sha256crypt" else flag
    ) old.configureFlags;
  });
in
import (inputs.proxmox-nixos + "/pkgs") {
  pkgs = prev // {
    lib = prev.lib // {
      callPackageWith =
        _:
        final.lib.callPackageWith (
          final
          // {
            # PVE depends on GlusterFS support removed in later QEMU
            qemu = mv.versions.qemu."10.2.2";
            libvncserver = mv.versions.libvncserver."0.9.14";
            # Compilation error with latest ceph
            inherit (mv.at "26.05") ceph;
            inherit libxcrypt;
          }
        );
    };
  };
}
