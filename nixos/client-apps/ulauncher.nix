{ pkgs, ... }:
{
  # Fix ulauncher startup error
  environment.systemPackages = with pkgs; [ ulauncher ];
  environment.pathsToLink = [ "/share/ulauncher" ];

  systemd.user.services.ulauncher.enable = false;
}
