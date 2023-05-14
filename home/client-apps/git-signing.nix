{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  programs.git.signing = {
    key = "B50EC319385FCB0D";
    # FIXME: reenable after gpg problem is fixed
    signByDefault = false;
  };
}
