{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  programs.adb.enable = true;

  programs.an-anime-game-launcher.enable = true;

  programs.java.enable = true;

  programs.steam.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  services.udev.packages = with pkgs; [
    libfido2
  ];

  users.users.lantian.extraGroups = ["adbusers" "wireshark"];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
