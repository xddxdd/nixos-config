{ inputs, lib, ... }:

final: prev: rec {
  flake = inputs;
  secrets = inputs.secrets;
}
