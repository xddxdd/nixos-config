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
      linger = LT.this.hasTag LT.tags.client;
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
    };
    lantian = {
      hashedPassword = lib.mkForce unixHashedPassword;
      isNormalUser = true;
      isSystemUser = lib.mkForce false;
      description = "Lan Tian";
      group = "lantian";
      extraGroups = [
        # keep-sorted start
        "dialout"
        "kvm"
        "systemd-journal"
        "users"
        "wheel"
        # keep-sorted end
      ];
      uid = 1000;
      openssh.authorizedKeys.keys = sshKeys;
      createHome = true;
      linger = LT.this.hasTag LT.tags.client;
      subUidRanges = [
        {
          startUid = 200000;
          count = 65536;
        }
      ];
    };
    nix-builder = lib.mkIf (LT.this.hasTag LT.tags.nix-builder) {
      isNormalUser = true;
      isSystemUser = lib.mkForce false;
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

  # Disable builtin subuid/subgid file management
  environment.etc.subuid.enable = false;
  environment.etc.subgid.enable = false;
}
