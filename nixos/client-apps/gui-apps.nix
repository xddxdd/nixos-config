{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  programs.java.enable = true;

  programs.steam.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  services.udev.packages = with pkgs; [
    android-udev-rules
    libfido2
  ];

  users.users.lantian.extraGroups = [ "wireshark" ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
