{ inputs, nixpkgs, ... }:

final: prev: rec {
  flake = inputs;
  secrets = inputs.secrets;
}
