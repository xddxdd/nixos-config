{ pkgs, config, ... }:
{
  xdg.dataFile."applications/mimeapps.list".enable = false;
  xdg.dataFile.applications.source = pkgs.linkFarm "applications" {
    "mimeapps.list" = config.xdg.dataFile."applications/mimeapps.list".source;
  };
}
