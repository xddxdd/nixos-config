{ config, pkgs, lib, ... }:

{
  programs.git.signing.gpgPath = lib.mkForce "/usr/bin/gpg";
}
