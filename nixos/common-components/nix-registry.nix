{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  registeredInputs = {
    nixpkgs = LT.patchedPkgs.nixpkgs;
    nur = inputs.nur.outPath;
    nur-xddxdd = inputs.nur-xddxdd.outPath;
  };
in {
  environment.etc = lib.mapAttrs' (n: v:
    lib.nameValuePair "nix/inputs/${n}" {
      source = lib.mkForce v;
    })
  registeredInputs;

  nix = {
    channel.enable = false;
    nixPath = ["/etc/nix/inputs"];
    registry =
      lib.mapAttrs (n: v: {
        flake = lib.mkForce {
          outPath = v;
        };
      })
      registeredInputs;
  };
}
