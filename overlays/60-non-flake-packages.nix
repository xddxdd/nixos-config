{ inputs, ... }:
final: prev: {
  dwarffs = inputs.dwarffs.packages."${final.system}".default;
}
