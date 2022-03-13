{ config, pkgs, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };
in
{
  services.syncthing = {
    enable = true;
    user = "rslsync";
    group = "rslsync";
    configDir = "/var/lib/syncthing";
    dataDir = "/nix/persistent/sync-servers";

    devices = pkgs.lib.mapAttrs (n: v: {
      autoAcceptFolders = false;
      id = v.syncthing;
      introducer = false;
    }) (pkgs.lib.filterAttrs (n: v: v.syncthing != "") LT.otherHosts);

    folders."sync-servers" = {
      path = "/nix/persistent/sync-servers";
      devices = builtins.attrNames (pkgs.lib.filterAttrs (n: v: v.syncthing != "") LT.otherHosts);
      ignorePerms = true;
      ignoreDelete = false;
    };
  };

  environment.systemPackages = [ config.services.syncthing.package ];

  # Reuse user of resilio sync
  users.users.rslsync = {
    uid = config.ids.uids.rslsync;
    group = "rslsync";
  };
  users.groups.rslsync = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/syncthing 755 rslsync rslsync"
    "d /nix/persistent/sync-servers 775 root root"
    "A+ /nix/persistent/sync-servers - - - - u:rslsync:rwx,g:rslsync:rwx,d:u:rslsync:rwx,d:g:rslsync:rwx"
  ];
}
