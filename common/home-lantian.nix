{ pkgs, inputs, ... }:

{
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Lan Tian";
    userEmail = "xuyh0120@outlook.com";
  };
}
