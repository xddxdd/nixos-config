{ pkgs, lib, config, utils, inputs, ... }@args:

let
  sshKeys = import (inputs.secrets + "/ssh/sftp.nix");
  sftpRoot = "/nix/persistent/sftp-server";
in
{
  users.users.sftp = {
    uid = 22;
    home = sftpRoot;
    group = "sftp";
    createHome = true;
    openssh.authorizedKeys.keys = sshKeys;
  };

  users.groups.sftp = {
    gid = 22;
  };

  services.openssh.extraConfig = ''
    Match User sftp
      ForceCommand internal-sftp
      PasswordAuthentication no
      ChrootDirectory ${sftpRoot}
      PermitTunnel no
      AllowAgentForwarding no
      AllowTcpForwarding no
      X11Forwarding no
  '';
}
