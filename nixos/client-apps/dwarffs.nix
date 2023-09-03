{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  imports = [inputs.dwarffs.nixosModules.dwarffs];
}
