{
  lib,
  LT,
  inputs,
  ...
}:
let
  registeredInputs = {
    nixpkgs = LT.patchedNixpkgs;
    nur = inputs.nur.outPath;
    nur-xddxdd = inputs.nur-xddxdd.outPath;
  };
in
{
  environment.etc = lib.mapAttrs' (
    n: v: lib.nameValuePair "nix/inputs/${n}" { source = lib.mkForce v; }
  ) registeredInputs;

  nix = {
    nixPath = [ "/etc/nix/inputs" ];
    registry = lib.mkForce (
      lib.mapAttrs (n: v: {
        to = lib.mkForce {
          type = "path";
          path = v;
        };
      }) registeredInputs
    );
  };

  # Disable conflicting settings from nixpkgs
  nixpkgs.flake = {
    setFlakeRegistry = false;
    setNixPath = false;
  };
}
