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

  programs.java.enable = true;

  programs.steam.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  services.udev.packages = with pkgs; [
    libfido2
  ];

  systemd.services.adbd = {
    description = "ADB Daemon";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "forking";
      User = "root";
      ExecStart = "${pkgs.android-tools}/bin/adb start-server";
      ExecStop = "${pkgs.android-tools}/bin/adb kill-server";
    };
  };

  users.users.lantian.extraGroups = ["adbusers" "wireshark"];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
