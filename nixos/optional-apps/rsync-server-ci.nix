{
  pkgs,
  lib,
  config,
  inputs,
  LT,
  ...
}:
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
    uid = 1001;
    openssh.authorizedKeys.keys = builtins.map (
      key: "command=\"${lib.getExe pkgs.rrsync} ${config.users.users.ci.home}\",restrict ${key}"
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
    device = "/nix/sync-servers";
    fsType = "fuse.bindfs";
    options = LT.constants.bindfsMountOptions' [
      "force-user=ci"
      "force-group=ci"
      "perms=700"
      "create-for-user=root"
      "create-for-group=root"
      "create-with-perms=755"
      "chmod-ignore"
    ];
  };
}
