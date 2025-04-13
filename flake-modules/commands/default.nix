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
      commands = lib.mapAttrs (_k: v: pkgs.callPackage v extraArgs) {
        asterisk-music-deploy = ./asterisk-music-deploy.nix;
        colmena = ./colmena.nix;
        check = ./check.nix;
        dnscontrol = ./dnscontrol.nix;
        nvfetcher = ./nvfetcher.nix;
        secrets = ./secrets.nix;
        update = ./update.nix;
        update-data = ./update-data.nix;
      };
    };
}
