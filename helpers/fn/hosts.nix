{
  lib,
  geo,
  tags,
  constants,
  hostsBase,
  ...
}:
lib.mapAttrs (
  n: _:
  (lib.evalModules {
    modules = [
      ../host-options.nix
      (hostsBase + "/${n}/host.nix")
    ];
    specialArgs = {
      inherit geo tags constants;
      name = n;
    };
  }).config
) (builtins.readDir hostsBase)
