{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  home.file.".nix-environments".source = inputs.nix-environments + "/envs";
}
