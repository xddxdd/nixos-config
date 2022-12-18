{ lib, ... }:

{
  # https://github.com/zhaofengli/colmena/blob/main/src/nix/hive/eval.nix
  mkColmenaHive = metaConfig: nixosConfigurations: with builtins; rec {
    __schema = "v0";
    inherit metaConfig;

    nodes = nixosConfigurations;
    toplevel = lib.mapAttrs (_: v: v.config.system.build.toplevel) nodes;
    deploymentConfig = lib.mapAttrs (_: v: v.config.deployment) nodes;
    deploymentConfigSelected = names: lib.filterAttrs (name: _: elem name names) deploymentConfig;
    evalSelected = names: lib.filterAttrs (name: _: elem name names) toplevel;
    evalSelectedDrvPaths = names: lib.mapAttrs (_: v: v.drvPath) (evalSelected names);
    introspect = f: f { inherit lib; pkgs = nixpkgs; nodes = uncheckedNodes; };
  };
}
