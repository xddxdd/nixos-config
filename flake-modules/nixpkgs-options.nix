{
  self,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    { system, ... }:
    rec {
      packages.nixpkgs-patched =
        let
          ls = dir: builtins.map (f: (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));
        in
        (import inputs.nixpkgs { inherit system; }).applyPatches {
          name = "nixpkgs-patched";
          src = inputs.nixpkgs;
          patches = ls ../patches/nixpkgs;
        };

      # This sets `pkgs` to a nixpkgs with allowUnfree option set.
      _module.args.pkgs = import packages.nixpkgs-patched {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-11.5.0"
            "electron-19.1.9"
            "nix-2.15.3"
            "openssl-1.1.1w"
            "python-2.7.18.8"
            "netbox-3.6.9"
          ];
        };
        overlays = [
          inputs.agenix.overlays.default
          inputs.colmena.overlay
          inputs.nil.overlays.nil
          inputs.nix-alien.overlays.default
          inputs.nur.overlay
          inputs.nur-xddxdd.overlay
          inputs.nvfetcher.overlays.default
        ] ++ (import ../overlays { inherit inputs; });
      };
    };
}
