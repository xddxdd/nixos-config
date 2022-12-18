{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  programs.git.signing = {
    key = "B50EC319385FCB0D";
    signByDefault = true;
  };
}
