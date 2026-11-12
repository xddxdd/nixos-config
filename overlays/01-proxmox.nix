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
            # PVE's Makefiles resolve fuse through pkg-config in the same call
            # as glib-2.0, and fuse3 ships no fuse.pc
            fuse = mv.versions.fuse."2.9.9";
            # vncterm's tls-auth-pluging.patch targets the 0.9.13 source layout
            # and no longer applies to 0.9.15
            libvncserver = mv.versions.libvncserver."0.9.14";
            inherit libxcrypt;
          }
        );
    };
  };
}
