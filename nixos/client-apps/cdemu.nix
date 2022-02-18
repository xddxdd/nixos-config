{ config, pkgs, ... }:

{
  programs.cdemu = {
    enable = true;
    group = "wheel";
    gui = true;
    image-analyzer = true;
  };
}
