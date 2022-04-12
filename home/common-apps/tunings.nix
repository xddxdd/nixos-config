{ config, pkgs, lib, ... }:

{
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        autoCrlf = "input";
      };
      pull = {
        rebase = false;
      };
    };
    userName = "Lan Tian";
    userEmail = "xuyh0120@outlook.com";
  };

  xdg.configFile = {
    "htop/htoprc".source = ../files/htoprc;
    "nixpkgs/config.nix".text = ''
      { allowUnfree = true; }
    '';
  };
}
