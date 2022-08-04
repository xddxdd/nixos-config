{ pkgs, lib, config, ... }:

let
  fuseMount = pkgs.writeShellScript "mount.fuse.nullfs" ''
    shift
    exec ${pkgs.nullfs}/bin/nullfs "$@"
  '';

  nullfs = pkgs.runCommand "nullfs" { } ''
    mkdir -p $out/bin $out/lib/systemd/system
    ln -s ${pkgs.nullfs}/bin/nullfs $out/bin/nullfs
    ln -s ${fuseMount} $out/bin/mount.fuse.nullfs
    cp ${./run-nullfs.mount} $out/lib/systemd/system/run-nullfs.mount
    cp ${./run-nullfs.automount} $out/lib/systemd/system/run-nullfs.automount
  '';
in
lib.mkIf (!(builtins.hasAttr "/run/nullfs" config.fileSystems))
{
  systemd.packages = [ nullfs ];
  system.fsPackages = [ nullfs ];
  systemd.units."run-nullfs.automount".wantedBy = [ "multi-user.target" ];
}
