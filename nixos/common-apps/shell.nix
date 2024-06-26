{
  pkgs,
  LT,
  config,
  ...
}:
{
  console.colors = [
    "000000"
    "ff5370"
    "c3e88d"
    "ffcb6b"
    "82aaff"
    "c792ea"
    "89ddff"
    "ffffff"
    "545454"
    "ff5370"
    "c3e88d"
    "ffcb6b"
    "82aaff"
    "c792ea"
    "89ddff"
    "ffffff"
  ];

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
