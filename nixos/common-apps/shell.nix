{ pkgs, lib, LT, config, utils, inputs, ... }@args:

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
    enable = true;
    enableGlobalCompInit = false;
  };
  users.defaultUserShell = pkgs.zsh;
}
