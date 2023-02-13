{ pkgs, lib, LT, config, utils, inputs, ... }@args:

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
  age.secrets.nix-s3-secret.file = inputs.secrets + "/nix/s3-secret.age";

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      !include ${config.age.secrets.nix-access-token.path}
    '';

    gc = {
      automatic = !(builtins.elem LT.tags.client LT.this.tags);
      options = "--delete-older-than 7d";
      randomizedDelaySec = "1h";
    };
    generateNixPathFromInputs = true;
    generateRegistryFromInputs = true;
    linkInputs = true;
    optimise.automatic = true;
    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = lib.mkForce "nix-command flakes ca-derivations";
      fallback = true;
      keep-going = true;
      keep-outputs = true;
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
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /run/nix-privkey.pem - - - - ${config.age.secrets.nix-privkey.path}"
    "L+ /root/.aws/credentials - - - - ${config.age.secrets.nix-s3-secret.path}"
  ];
}
