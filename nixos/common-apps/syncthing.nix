{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  services.syncthing = {
    enable = true;
    user = "root";
    group = "root";
    configDir = "/var/lib/syncthing";
    dataDir = "/nix/persistent/sync-servers";

    devices = lib.mapAttrs
      (n: v: {
        autoAcceptFolders = false;
        id = v.syncthing;
        introducer = false;
      })
      (lib.filterAttrs (n: v: v.syncthing != "") LT.otherHosts);

    folders."sync-servers" = {
      path = "/nix/persistent/sync-servers";
      devices = builtins.attrNames (lib.filterAttrs (n: v: v.syncthing != "") LT.otherHosts);
      type =
        if (config.systemd.services.drone.enable or false)
        then "sendreceive" else "receiveonly";
      ignorePerms = true;
      ignoreDelete = false;
    };
  };

  environment.systemPackages = [ config.services.syncthing.package ];

  systemd.services.syncthing.environment = {
    GOGC = "1";
    LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/syncthing 755 root root"
    "d /nix/persistent/sync-servers 775 root root"
  ];
}
