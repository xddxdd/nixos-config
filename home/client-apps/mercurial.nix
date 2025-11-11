{ pkgs, config, ... }:
{
  programs.mercurial = {
    enable = true;
    package = pkgs.mercurialFull;
    userName = config.programs.git.settings.user.name;
    userEmail = config.programs.git.settings.user.email;
  };
}
