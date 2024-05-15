{ pkgs, ... }:
{
  programs.java.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  services.udev.packages = with pkgs; [ libfido2 ];

  users.users.lantian.extraGroups = [ "wireshark" ];
}
