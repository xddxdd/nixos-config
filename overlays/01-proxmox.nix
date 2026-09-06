{ inputs, ... }:
final: prev:
let
  mv = inputs.nixpkgs-multiverse.multiverse.${final.stdenv.hostPlatform.system};
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
          }
        );
    };
  };
}
