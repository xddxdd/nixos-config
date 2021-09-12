# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "main" "brackets" "pattern" ];
    };
    vteIntegration = true;
    promptInit = ''
      ${pkgs.neofetch}/bin/neofetch

      source ${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k/powerlevel9k.zsh-theme

      POWERLEVEL9K_PROMPT_ON_NEWLINE=true
      POWERLEVEL9K_DISABLE_RPROMPT=true
      POWERLEVEL9K_STATUS_VERBOSE=false
      POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=""
      POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=""
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time status dir_writable vcs context anaconda dir_joined)
      #POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time status dir_writable vcs context dir_joined)
      POWERLEVEL9K_SHORTEN_DIR_LENGTH=100
      #POWERLEVEL9K_SHORTEN_DELIMITER=".."
      #POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_unique"
      POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
      POWERLEVEL9K_CONTEXT_TEMPLATE="%n"
      if [ $USER = "root" ]
      then
        POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%K{red}%F{white} # %k%f "
        POWERLEVEL9K_TIME_FOREGROUND='white'
        POWERLEVEL9K_TIME_BACKGROUND='red'
      else
        POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%K{white}%F{black} $ %k%f "
      fi
    '';
    ohMyZsh = {
      enable = true;
    };
  };
}
