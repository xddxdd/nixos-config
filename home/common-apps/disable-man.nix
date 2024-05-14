{ lib, ... }:
{
  programs.man.enable = lib.mkForce false;
}
