{
  lib,
  LT,
  config,
  inputs,
  pkgs,
  ...
}:
let
  allowedUsers = [
    "@wheel"
    "@hydra"
    "nix-builder"
    "root"
  ];
in
{
  age.secrets.nix-access-token = {
    file = inputs.secrets + "/nix/access-token.age";
    group = "wheel";
    mode = "0444";
  };
  age.secrets.nix-privkey = {
    name = "nix-privkey.pem";
    file = inputs.secrets + "/nix/privkey.age";
  };
  age.secrets.nix-netrc = {
    file = inputs.secrets + "/nix/netrc.age";
    group = "wheel";
    mode = "0444";
  };

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
    extraOptions = ''
      !include ${config.age.secrets.nix-access-token.path}
    '';

    daemonCPUSchedPolicy = if LT.this.hasTag LT.tags.client then "idle" else "batch";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      randomizedDelaySec = "1h";
    };
    nrBuildUsers = 0;
    optimise.automatic = true;
    settings = {
      allowed-users = lib.mkForce allowedUsers;
      auto-allocate-uids = true;
      auto-optimise-store = true;
      build-dir = "/var/cache/nix";
      builders-use-substitutes = true;
      connect-timeout = 5;
      download-buffer-size = 1024 * 1024 * 1024;
      experimental-features = lib.mkForce "nix-command flakes ca-derivations auto-allocate-uids cgroups";
      extra-experimental-features = lib.mkForce "nix-command flakes ca-derivations auto-allocate-uids cgroups";
      fallback = true;
      keep-going = true;
      keep-outputs = true;
      log-lines = 25;
      max-free = 1000 * 1000 * 1000;
      min-free = 128 * 1000 * 1000;
      trusted-users = allowedUsers;
      use-cgroups = true;
      warn-dirty = false;
      netrc-file = config.age.secrets.nix-netrc.path;
      use-xdg-base-directories = true;

      # # Determinate Nix specific
      # eval-cores = 0;
      # max-jobs = "auto";
      # lazy-trees = true;

      substituters = lib.mkForce (
        [ "https://cache.nixos.org" ] ++ config.nix.settings.trusted-substituters
      );
      trusted-substituters = LT.constants.nix.substituters;
      inherit (LT.constants.nix) trusted-public-keys;
    };
  };

  systemd.services.nix-daemon = {
    serviceConfig = {
      CacheDirectory = "nix";
      Nice = 19;
      OOMScoreAdjust = 250;
    };
  };

  systemd.timers.nix-gc.timerConfig.Persistent = lib.mkForce "false";

  systemd.tmpfiles.settings = {
    nix-privkey = {
      "/run/nix-privkey.pem"."L+" = {
        argument = "${config.age.secrets.nix-privkey.path}";
      };
    };
  };
}
