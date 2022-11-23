{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
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
      experimental-features = nix-command flakes ca-derivations
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
      auto-optimise-store = true;
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
