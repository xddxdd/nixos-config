{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  sshKeys = import (inputs.secrets + "/ssh/rsync-ci.nix");
in
{
  users.users.ci = {
    home = "/run/rsync-ci";
    group = "ci";
    createHome = true;
    # Must be normal user to allow SSH login
    isNormalUser = true;
    openssh.authorizedKeys.keys = builtins.map (
      key: "command=\"${pkgs.rrsync}/bin/rrsync ${config.users.users.ci.home}\",restrict ${key}"
    ) sshKeys;
  };

  users.groups.ci = { };

  services.openssh.extraConfig = ''
    Match User ci
      PasswordAuthentication no
      PermitTunnel no
      AllowAgentForwarding no
      AllowTcpForwarding no
      X11Forwarding no
  '';

  fileSystems."/run/rsync-ci" = {
    device = "/nix/persistent/sync-servers";
    fsType = "fuse.bindfs";
    options = [
      "force-user=ci"
      "force-group=ci"
      "perms=755"
      "create-for-user=root"
      "create-for-group=root"
      "chmod-ignore"
      "chown-ignore"
      "chgrp-ignore"
      "xattr-none"
      "x-gvfs-hide"
    ];
  };
}
