{ lib, config, ... }:
{
  assertions = [
    {
      assertion = !builtins.elem "man" config.home.extraOutputsToInstall;
      message = "man pages still included in output";
    }
  ];

  manual = {
    html.enable = false;
    manpages.enable = false;
    json.enable = false;
  };

  programs.info.enable = false;

  programs.man = {
    enable = lib.mkForce false;
    package = lib.mkForce null;
    generateCaches = lib.mkForce false;
  };
}
