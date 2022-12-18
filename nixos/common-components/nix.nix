{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  age.secrets.nix-access-token.file = inputs.secrets + "/nix/access-token.age";
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

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      randomizedDelaySec = "1h";
    };
    generateNixPathFromInputs = true;
    generateRegistryFromInputs = true;
    linkInputs = true;
    optimise.automatic = true;
    settings = {
      # https://jackson.dev/post/nix-reasonable-defaults/
      auto-optimise-store = true;
      connect-timeout = 5;
      experimental-features = "nix-command flakes ca-derivations";
      fallback = true;
      keep-going = true;
      keep-outputs = true;
      log-lines = 25;
      max-free = 1024 * 1024 * 1024;
      min-free = 128 * 1024 * 1024;
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
