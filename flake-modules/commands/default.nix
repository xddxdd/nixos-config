{
  self,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      extraArgs = {
        inherit inputs;
        LT = import ../../helpers { inherit lib inputs pkgs; };
        packages = self.packages."${pkgs.system}";
      };
    in
    {
      commands = lib.mapAttrs (k: v: pkgs.callPackage v extraArgs) {
        asterisk-music-deploy = ./asterisk-music-deploy.nix;
        ci = ./ci.nix;
        colmena = ./colmena.nix;
        check = ./check.nix;
        dnscontrol = ./dnscontrol.nix;
        nvfetcher = ./nvfetcher.nix;
        update-data = ./update-data.nix;
        update-flake = ./update-flake.nix;
      };
    };
}
