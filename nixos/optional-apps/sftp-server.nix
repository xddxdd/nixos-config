{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  sshKeys = import (inputs.secrets + "/ssh/sftp.nix");
in
{
  users.users.sftp = {
    uid = 22;
    home = "/nix/persistent/sftp-server";
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
      ChrootDirectory ${config.users.users.sftp.home}
      PermitTunnel no
      AllowAgentForwarding no
      AllowTcpForwarding no
      X11Forwarding no
  '';
}
