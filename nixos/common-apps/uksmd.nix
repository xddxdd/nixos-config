{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  systemd.packages = with pkgs; [uksmd];
  systemd.services.uksmd = {
    enable = true;
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      CPUQuota = "10%";
    };
  };
}
