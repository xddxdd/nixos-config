{ pkgs, lib, ... }:
{
  home.file.".gitignore".text = ''
    .pi
    .pi-*
  '';

  programs.git = {
    package = lib.mkForce pkgs.git;
    settings.core.excludesfile = "~/.gitignore";
    signing = {
      key = "B50EC319385FCB0D";
      format = "openpgp";
      signByDefault = true;
    };
  };
}
