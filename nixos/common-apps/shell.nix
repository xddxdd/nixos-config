{
  pkgs,
  LT,
  config,
  ...
}:
{
  environment.pathsToLink = [ "/share/zsh" ];
  environment.shells = [ pkgs.zsh ];
  environment.variables = {
    TERM = "xterm-256color";
  };

  programs.zsh = {
    enable = LT.this.hasTag LT.tags.client;
    enableGlobalCompInit = false;
  };
  users.defaultUserShell = if config.programs.zsh.enable then pkgs.zsh else pkgs.bash;
}
