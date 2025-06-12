{ inputs, ... }:
final: prev: {
  composer2nix = final.callPackage inputs.composer2nix { };
  dwarffs = inputs.dwarffs.packages."${final.system}".default;
}
