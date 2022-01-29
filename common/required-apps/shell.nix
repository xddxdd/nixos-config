{ config, pkgs, ... }:

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

  environment.shells = [ pkgs.zsh ];
  environment.systemPackages = with pkgs; [
    zsh-powerlevel10k
    neofetch
  ];
  environment.variables = {
    TERM = "xterm-256color";
  };

  environment.etc."neofetch.conf" = {
    source = ../files/neofetch.conf;
    mode = "0755";
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
