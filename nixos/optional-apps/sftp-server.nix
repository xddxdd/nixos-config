{ config, pkgs, ... }:

let
  sshKeys = import (pkgs.secrets + "/ssh/sftp.nix");
  sftpRoot = "/nix/persistent/sftp-server";
in
{
  users.users.sftp = {
    uid = 22;
    home = "${sftpRoot}/sftp";
    group = "sftp";
    createHome = true;
    openssh.authorizedKeys.keys = sshKeys;
  };

  users.groups.sftp = {
    gid = 22;
  };

  services.openssh.extraConfig = ''
    Match User sftp
      ForceCommand internal-sftp -d /sftp
      PasswordAuthentication no
      ChrootDirectory ${sftpRoot}
      PermitTunnel no
      AllowAgentForwarding no
      AllowTcpForwarding no
      X11Forwarding no
  '';

  systemd.tmpfiles.rules = [
    "d ${sftpRoot} 755 root root"
  ];
}
