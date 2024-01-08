{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
} @ args: {
  imports = [
    ./eval.nix
    ./options.nix
    ./record-handlers.nix
  ];
}
