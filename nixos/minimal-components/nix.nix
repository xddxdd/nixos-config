{
  lib,
  LT,
  config,
  pkgs,
  inputs,
  ...
}:
let
  allowedUsers = [
    "@wheel"
    "@hydra"
    "nix-ssh"
    "root"
  ];
  sshKeysForNixServe = import (inputs.secrets + "/ssh/nix-builder.nix");
in
{
  services.angrr = {
    enable = true;
    settings = {
      temporary-root-policies = {
        direnv = {
          path-regex = "/\\.direnv/";
          period = "14d";
        };
        result = {
          path-regex = "/result[^/]*$";
          period = "3d";
        };
      };
      profile-policies = {
        system = {
          profile-paths = [ "/nix/var/nix/profiles/system" ];
          keep-since = "14d";
          keep-latest-n = 5;
          keep-booted-system = true;
          keep-current-system = true;
        };
        user = {
          enable = false; # Policies can be individually disabled
          profile-paths = [
            "~/.local/state/nix/profiles/profile"
            "/nix/var/nix/profiles/per-user/root/profile"
          ];
          keep-since = "1d";
          keep-latest-n = 1;
        };
      };
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;

    sshServe = {
      enable = LT.this.hasTag LT.tags.nix-builder;
      # nix-ssh must stay in allowedUsers above for trusted-users/allowed-users
      # access; nix.sshServe.trusted would only duplicate the entry.
      keys = sshKeysForNixServe;
      protocol = "ssh-ng";
    };

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      randomizedDelaySec = "1h";
    };
    optimise.automatic = true;

    nrBuildUsers = 0;
    settings = {
      allowed-users = lib.mkForce allowedUsers;
      auto-allocate-uids = true;
      auto-optimise-store = true;
      build-dir = "/var/cache/nix";
      builders-use-substitutes = true;
      connect-timeout = 5;
      # download-buffer-size = 1024 * 1024 * 1024;  # Removed in Lix
      experimental-features = lib.mkForce [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
        "cgroups"
      ];
      extra-experimental-features = lib.mkForce [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
        "cgroups"
      ];
      fallback = true;
      keep-going = true;
      keep-outputs = true;
      log-lines = 25;
      max-free = 1000 * 1000 * 1000;
      min-free = 128 * 1000 * 1000;
      trusted-users = allowedUsers;
      use-cgroups = true;
      warn-dirty = false;
      use-xdg-base-directories = true;

      # # Determinate Nix specific
      # eval-cores = 0;
      # max-jobs = "auto";
      # lazy-trees = true;

      substituters = [ "https://cache.nixos.org" ] ++ config.nix.settings.trusted-substituters;
      system-features =
        lib.optionals (LT.this.system == "x86_64-linux") [ "gccarch-x86-64" ]
        ++ lib.optionals (LT.this.x86ArchLevel != null && LT.this.x86ArchLevel >= 2) [ "gccarch-x86-64-v2" ]
        ++ lib.optionals (LT.this.x86ArchLevel != null && LT.this.x86ArchLevel >= 3) [ "gccarch-x86-64-v3" ]
        ++ lib.optionals (LT.this.x86ArchLevel != null && LT.this.x86ArchLevel >= 4) [
          "gccarch-x86-64-v4"
        ];
      trusted-substituters = LT.constants.nix.substituters;
      inherit (LT.constants.nix) trusted-public-keys;
    };
  };

  systemd.services.nix-daemon = {
    serviceConfig = {
      CacheDirectory = "nix";
      Nice = 19;
      OOMScoreAdjust = 1000;
    };
  };
}
