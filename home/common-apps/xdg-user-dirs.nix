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
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    publicShare = "/var/empty";
    templates = "/var/empty";
    videos = "$HOME/Videos";
  };
}
