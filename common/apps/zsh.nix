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

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    autosuggestions.enable = true;
    vteIntegration = true;
    promptInit = import ../helpers/zshrc.nix { inherit config pkgs; };
    ohMyZsh = {
      enable = true;
    };
  };

  environment.etc."neofetch.conf" = {
    source = ../files/neofetch.conf;
    mode = "0755";
  };
}
