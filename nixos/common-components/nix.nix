{ config, pkgs, lib, ... }:

{

  age.secrets.nix-access-token.file = pkgs.secrets + "/nix/access-token.age";
  age.secrets.nix-privkey = {
    name = "nix-privkey.pem";
    file = pkgs.secrets + "/nix/privkey.age";
  };
  age.secrets.nix-s3-secret.file = pkgs.secrets + "/nix/s3-secret.age";

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
      substituters = [
        "s3://nix?endpoint=s3.xuyh0120.win"
        "https://cache.ngi0.nixos.org"
        "https://xddxdd.cachix.org"
        "https://colmena.cachix.org"
        "https://nixos-cn.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "nix:FXFCqBRF2PXcExvV31yQQHZTyRnIsnLZiHtu/i0xZ1c="
        "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
        "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        "nixos-cn.cachix.org-1:L0jEaL6w7kwQOPlLoCR3ADx+E3Q8SEFEcB9Jaibl0Xg="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /run/nix-privkey.pem - - - - ${config.age.secrets.nix-privkey.path}"
    "L+ /root/.aws/credentials - - - - ${config.age.secrets.nix-s3-secret.path}"
  ];
}
