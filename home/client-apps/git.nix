{ pkgs, lib, ... }:
{
  home.file.".gitignore".text = ''
    .pi-*
  '';

  programs.git = {
    package = lib.mkForce pkgs.git;
    extraConfig.core.excludesfile = "~/.gitignore";
    signing = {
      key = "B50EC319385FCB0D";
      format = "openpgp";
      signByDefault = true;
    };
  };
}
