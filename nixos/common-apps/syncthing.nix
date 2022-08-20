{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  syncthingCli = pkgs.writeShellScriptBin "syncthing-cli" ''
    exec ${config.services.syncthing.package}/bin/syncthing cli --home /var/lib/syncthing "$@"
  '';
in
{
  services.syncthing = {
    enable = true;
    user = "rslsync";
    group = "rslsync";
    configDir = "/var/lib/syncthing";
    dataDir = "/nix/persistent/sync-servers";

    extraOptions = {
      options = {
        localAnnounceEnabled = false;
        announceLANAddresses = false;
        maxSendKbps = 100;
        maxRecvKbps = 100;
      };
    };

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

  environment.systemPackages = [ config.services.syncthing.package syncthingCli ];

  # Reuse user of resilio sync
  users.users.rslsync = {
    uid = config.ids.uids.rslsync;
    group = "rslsync";
  };
  users.groups.rslsync = { };

  systemd.services.syncthing.environment = {
    LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/syncthing 755 rslsync rslsync"
    "d /nix/persistent/sync-servers 775 root root"
    "A+ /nix/persistent/sync-servers - - - - u:rslsync:rwx,g:rslsync:rwx,d:u:rslsync:rwx,d:g:rslsync:rwx"
  ];
}
