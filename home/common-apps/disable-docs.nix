{ lib, ... }:
{
  manual = {
    html.enable = false;
    manpages.enable = false;
    json.enable = false;
  };

  programs.info.enable = false;

  programs.man = {
    enable = lib.mkForce false;
    generateCaches = lib.mkForce false;
  };
}
