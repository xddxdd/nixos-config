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
      key = "3B39369B37BC4FF9";
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
