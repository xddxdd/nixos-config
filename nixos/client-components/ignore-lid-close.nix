{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  # Disable suspend on lid close
  services.upower.ignoreLid = true;
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
}
