{
  lib,
  geo,
  tags,
  hostsBase,
  ...
}:
lib.genAttrs (builtins.attrNames (builtins.readDir hostsBase)) (
  n:
  (lib.evalModules {
    modules = [
      ../host-options.nix
      (hostsBase + "/${n}/host.nix")
    ];
    specialArgs = {
      inherit geo tags;
      name = n;
    };
  }).config
)
