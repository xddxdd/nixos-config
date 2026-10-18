{
  pkgs,
  lib,
  config,
  inputs,
  LT,
  ...
}:
let
  sshKeys = import (inputs.secrets + "/ssh/rsync-internal.nix");
in
{
  users.users.rsync-internal = {
    home = "/run/rsync-internal";
    group = "rsync-internal";
    createHome = true;
    # Must be normal user to allow SSH login
    isNormalUser = true;
    uid = 1002;
    openssh.authorizedKeys.keys = builtins.map (
      key:
      "command=\"${lib.getExe pkgs.rrsync} -ro ${config.users.users.rsync-internal.home}\",restrict ${key}"
    ) sshKeys;
  };

  users.groups.rsync-internal = { };

  services.openssh.extraConfig = ''
    Match User rsync-internal
      PasswordAuthentication no
      PermitTunnel no
      AllowAgentForwarding no
      AllowTcpForwarding no
      X11Forwarding no
  '';

  fileSystems."/run/rsync-internal" = {
    # Folder created in nixos/minimal-apps/rsync-internal.nix
    device = "/nix/sync-servers";
    fsType = "fuse.bindfs";
    options = LT.constants.bindfsMountOptions' [
      "force-user=rsync-internal"
      "force-group=rsync-internal"
      "perms=700"
      "create-for-user=root"
      "create-for-group=root"
      "create-with-perms=755"
      "chmod-ignore"
    ];
  };
}
