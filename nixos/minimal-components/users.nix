{
  lib,
  inputs,
  LT,
  ...
}:
let
  # unixHashedPassword = import (inputs.secrets + "/unix-hashed-pw.nix");
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");
  unixHashedPassword = glauthUsers.lantian.passBcrypt;
  sshKeys = import (inputs.secrets + "/ssh/lantian.nix");
  sshKeysForNixBuilder = import (inputs.secrets + "/ssh/nix-builder.nix");
in
{
  environment.etc.subuid = {
    mode = "0644";
    text = ''
      root:100000:65536
      lantian:200000:65536
    '';
  };
  environment.etc.subgid = {
    mode = "0644";
    text = ''
      root:100000:65536
      lantian:200000:65536
    '';
  };

  services.userborn = {
    enable = true;
    passwordFilesLocation = "/nix/persistent/var/lib/nixos";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users = {
    root = {
      hashedPassword = lib.mkForce unixHashedPassword;
      openssh.authorizedKeys.keys = sshKeys;
      linger = true;
    };
    lantian = {
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
      linger = true;
    };
    nix-builder = lib.mkIf (LT.this.hasTag LT.tags.nix-builder) {
      isNormalUser = true;
      group = "nix-builder";
      openssh.authorizedKeys.keys = sshKeysForNixBuilder;
      linger = false;
    };
  };

  users.groups = {
    lantian = {
      gid = 1000;
    };
    nix-builder = { };
  };
}
