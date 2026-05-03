{ inputs, ... }:
final: prev: {
  nixfmt-rs = inputs.nixfmt-rs.packages."${prev.system}".default;
}
