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
  sshKeys = import (inputs.secrets + "/ssh/sftp-ci.nix");
in
{
  users.users.ci = {
    home = "/run/sftp-ci";
    group = "ci";
    createHome = true;
    isSystemUser = true;
    openssh.authorizedKeys.keys = sshKeys;
  };

  users.groups.ci = { };

  services.openssh.extraConfig = ''
    Match User ci
      ForceCommand internal-sftp
      PasswordAuthentication no
      ChrootDirectory ${config.users.users.ci.home}
      PermitTunnel no
      AllowAgentForwarding no
      AllowTcpForwarding no
      X11Forwarding no
  '';

  fileSystems."/run/sftp-ci" = {
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
