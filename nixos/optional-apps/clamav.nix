{
  pkgs,
  lib,
  LT,
  config,
  options,
  utils,
  inputs,
  ...
} @ args: {
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  systemd.services.clamav-freshclam.requires = ["network-online.target"];
}
