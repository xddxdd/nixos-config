{
  self,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    {
      config,
      system,
      pkgs,
      ...
    }:
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
    rec {
      apps = lib.mapAttrs (n: v: {
        type = "app";
        program = pkgs.writeShellScriptBin n (pkg v { });
      }) commands;

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = config.pre-commit.settings.enabledPackages ++ [
          config.pre-commit.settings.package
        ];
        shellHook = config.pre-commit.installationScript;

        buildInputs = lib.mapAttrsToList (
          n: _v:
          pkgs.writeShellScriptBin n ''
            exec nix run .#${n} -- "$@"
          ''
        ) apps;
      };
    };
}
