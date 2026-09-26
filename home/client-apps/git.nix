{
  pkgs,
  lib,
  config,
  ...
}:
{
  xdg.configFile."git/ignore" = {
    text = ''
      .pi
      .pi-*
    '';
    force = true;
  };

  programs.git = {
    package = lib.mkForce pkgs.git;
    settings.core.excludesfile = "${config.xdg.configHome}/git/ignore";
    signing = {
      key = "B50EC319385FCB0D";
      format = "openpgp";
      signByDefault = true;
    };
  };

  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      mode = "difftool";
    };
  };
}
