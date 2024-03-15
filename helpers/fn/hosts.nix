{
  lib,
  geo,
  tags,
  ...
}:
lib.genAttrs (builtins.attrNames (builtins.readDir ../../hosts)) (
  n:
  (lib.evalModules {
    modules = [
      ../host-options.nix
      (../../hosts + "/${n}/host.nix")
    ];
    specialArgs = {
      inherit geo tags;
      name = n;
    };
  }).config
)
