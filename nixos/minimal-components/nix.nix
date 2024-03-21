{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  age.secrets.nix-access-token = {
    file = inputs.secrets + "/nix/access-token.age";
    group = "wheel";
    mode = "0440";
  };
  age.secrets.nix-privkey = {
    name = "nix-privkey.pem";
    file = inputs.secrets + "/nix/privkey.age";
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      !include ${config.age.secrets.nix-access-token.path}
    '';

    daemonCPUSchedPolicy = if LT.this.hasTag LT.tags.client then "idle" else "batch";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;

    gc = {
      automatic = LT.this.hasTag LT.tags.server;
      options = "--delete-older-than 7d";
      randomizedDelaySec = "1h";
    };
    # Do not use auto-allocate-uids, permission issue with ccache
    # nrBuildUsers = 0;
    optimise.automatic = true;
    settings = {
      # auto-allocate-uids = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      connect-timeout = 5;
      experimental-features = lib.mkForce "nix-command flakes ca-derivations cgroups";
      extra-experimental-features = lib.mkForce "nix-command flakes ca-derivations cgroups";
      fallback = true;
      keep-going = true;
      keep-outputs = true;
      log-lines = 25;
      max-free = 1000 * 1000 * 1000;
      min-free = 128 * 1000 * 1000;
      trusted-users = [ "@wheel" ];
      use-cgroups = true;
      warn-dirty = false;

      substituters = LT.constants.nix.substituters ++ config.nix.settings.trusted-substituters;
      inherit (LT.constants.nix) trusted-public-keys;
    };
  };

  systemd.services.nix-daemon = {
    environment = {
      TMPDIR = "/var/cache/nix";
    };
    serviceConfig = {
      CacheDirectory = "nix";
      Nice = 19;
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /run/nix-privkey.pem - - - - ${config.age.secrets.nix-privkey.path}"
  ];
}
