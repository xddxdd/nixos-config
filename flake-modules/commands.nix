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
        LT = import ./helpers { inherit lib inputs pkgs; };
        packages = self.packages."${pkgs.system}";
      };
    in
    {
      commands = lib.mapAttrs (_k: v: pkgs.callPackage v extraArgs) {
        colmena = ../scripts/colmena.nix;
        check = ../scripts/check.nix;
        dnscontrol = ../scripts/dnscontrol.nix;
        nvfetcher = ../scripts/nvfetcher.nix;
        secrets = ../scripts/secrets.nix;
        update = ../scripts/update.nix;
      };
    };
}
