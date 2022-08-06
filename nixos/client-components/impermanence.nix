{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  bindfsMountOptions = [
    "force-user=lantian"
    "force-group=wheel"
    "create-for-user=rslsync"
    "create-for-group=rslsync"
    "chown-ignore"
    "chgrp-ignore"
    "xattr-none"
  ];
in
lib.mkIf (!config.boot.isContainer) {
  system.fsPackages = [ pkgs.bindfs ];

  fileSystems = {
    "/home/lantian/Backups" = {
      device = "/nix/persistent/media/Backups";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Calibre Library" = {
      device = "/nix/persistent/media/Calibre Library";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Music/CloudMusic" = {
      device = "/nix/persistent/media/CloudMusic";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Documents" = {
      device = "/nix/persistent/media/Documents";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/LegacyOS" = {
      device = "/nix/persistent/media/LegacyOS";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Pictures" = {
      device = "/nix/persistent/media/Pictures";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Secrets" = {
      device = "/nix/persistent/media/Secrets";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/Software" = {
      device = "/nix/persistent/media/Software";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
    "/home/lantian/.local/share/yuzu" = {
      device = "/nix/persistent/media/Yuzu";
      fsType = "fuse.bindfs";
      options = bindfsMountOptions;
    };
  };
}
