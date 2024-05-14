{
  self,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    { system, pkgs, ... }:
    let
      commands = {
        colmena = ../scripts/colmena.nix;
        check = ../scripts/check.nix;
        dnscontrol = ../scripts/dnscontrol.nix;
        nvfetcher = ../scripts/nvfetcher.nix;
        secrets = ../scripts/secrets.nix;
        terraform = ../scripts/terraform.nix;
        update = ../scripts/update.nix;
      };

      extraArgs = {
        inherit inputs;
        LT = import ./helpers { inherit lib inputs pkgs; };
        packages = self.packages."${pkgs.system}";
      };
      pkg = v: args: pkgs.callPackage v (extraArgs // args);
    in
    {
      apps = lib.mapAttrs (n: v: {
        type = "app";
        program = pkgs.writeShellScriptBin n (pkg v { });
      }) commands;
    };
}
