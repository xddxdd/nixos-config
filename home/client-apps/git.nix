{ pkgs, lib, ... }:
{
  programs.git = {
    package = lib.mkForce pkgs.git;
    signing = {
      key = "B50EC319385FCB0D";
      format = "openpgp";
      signByDefault = true;
    };
  };
}
