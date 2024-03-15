{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  environment.systemPackages = with pkgs; [ uksmd ];
  systemd.packages = with pkgs; [ uksmd ];
  systemd.services.uksmd = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      CPUQuota = "10%";
    };
  };
}
