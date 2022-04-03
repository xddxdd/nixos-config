{ config, pkgs, lib, ... }:

let
  hashedPassword = import (pkgs.secrets + "/config/unix-hashed-pw.nix");
  sshKeys = import (pkgs.secrets + "/ssh/lantian.nix");
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users = {
    root = {
      inherit hashedPassword;
      openssh.authorizedKeys.keys = sshKeys;
    };
    lantian = {
      inherit hashedPassword;
      isNormalUser = true;
      description = "Lan Tian";
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      uid = 1000;
      openssh.authorizedKeys.keys = sshKeys;
    };
    container = {
      uid = 65533;
      group = "container";
      isSystemUser = true;
    };
  };

  users.groups = {
    container = {
      gid = 65533;
    };
  };
}
