{ config, pkgs, lib, ... }:

{
  services.flexget = {
    enable = true;
    user = "lantian";
    systemScheduler = true;
    interval = "10m";
    homeDir = "/var/lib/flexget";
  };
  systemd.services.flexget.enable = false;
}