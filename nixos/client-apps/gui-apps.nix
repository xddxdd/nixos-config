{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  programs.java.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  services.udev.packages = with pkgs; [
    libfido2
  ];

  users.users.lantian.extraGroups = ["wireshark"];

  virtualisation.virtualbox.host = {
    enable = true;
    addNetworkInterface = false;
    enableHardening = false;
    enableKvm = true;
  };
}
