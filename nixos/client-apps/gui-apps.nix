{ pkgs, ... }:
{
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.java = {
    enable = true;
    binfmt = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  services.udev.packages = with pkgs; [ libfido2 ];

  users.users.lantian.extraGroups = [ "wireshark" ];
}
