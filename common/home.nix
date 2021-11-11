{ pkgs, inputs, ... }:

{
  home.file.".zshrc".text = ''
    # Created by home-manager
  '';

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Lan Tian";
    userEmail = "xuyh0120@outlook.com";
  };
}
