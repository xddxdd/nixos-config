{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  services.envfs.enable = true;
  fileSystems."/bin".neededForBoot = true;
  fileSystems."/usr/bin".neededForBoot = true;
}
