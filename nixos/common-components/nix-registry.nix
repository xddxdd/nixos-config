{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  environment.etc = lib.mapAttrs' (n: v:
    lib.nameValuePair "nix/inputs/${n}" {
      source = lib.mkForce v;
    })
  LT.patchedPkgs;

  nix = {
    generateNixPathFromInputs = true;
    generateRegistryFromInputs = true;
    linkInputs = true;

    registry =
      lib.mapAttrs (n: v: {
        flake = lib.mkForce {
          outPath = v;
        };
      })
      LT.patchedPkgs;
  };
}
