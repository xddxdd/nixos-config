{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
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

    gc = {
      automatic = builtins.elem LT.tags.server LT.this.tags;
      options = "--delete-older-than 7d";
      randomizedDelaySec = "1h";
    };
    nrBuildUsers = 0;
    optimise.automatic = true;
    settings = {
      auto-allocate-uids = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = lib.mkForce "nix-command flakes ca-derivations auto-allocate-uids cgroups";
      fallback = true;
      keep-going = true;
      keep-outputs = true;
      use-cgroups = true;
      warn-dirty = false;

      inherit (LT.constants.nix) substituters trusted-public-keys;
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
