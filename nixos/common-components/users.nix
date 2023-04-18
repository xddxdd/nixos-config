{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  # unixHashedPassword = import (inputs.secrets + "/unix-hashed-pw.nix");
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");
  unixHashedPassword = glauthUsers.lantian.passBcrypt;
  sshKeys = import (inputs.secrets + "/ssh/lantian.nix");
in {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users = {
    root = {
      initialHashedPassword = lib.mkForce unixHashedPassword;
      hashedPassword = lib.mkForce unixHashedPassword;
      openssh.authorizedKeys.keys = sshKeys;
    };
    lantian = {
      initialHashedPassword = lib.mkForce unixHashedPassword;
      hashedPassword = lib.mkForce unixHashedPassword;
      isNormalUser = true;
      description = "Lan Tian";
      group = "lantian";
      extraGroups = [
        "systemd-journal"
        "users"
        "wheel"
      ];
      uid = 1000;
      openssh.authorizedKeys.keys = sshKeys;
      createHome = true;
    };
    container = {
      uid = 65533;
      group = "container";
      isSystemUser = true;
    };
  };

  users.groups = {
    lantian = {
      gid = 1000;
    };
    container = {
      gid = 65533;
    };
  };
}
