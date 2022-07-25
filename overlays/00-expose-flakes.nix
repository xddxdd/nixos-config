{ inputs, lib, ... }:

final: prev: rec {
  flake = inputs;
  inherit (inputs) secrets;
}
