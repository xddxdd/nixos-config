{ inputs, ... }:
final: _prev: {
  composer2nix = final.callPackage inputs.composer2nix { };
  dwarffs = inputs.dwarffs.packages."${final.system}".default;
}
