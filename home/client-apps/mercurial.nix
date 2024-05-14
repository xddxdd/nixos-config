{ pkgs, config, ... }:
{
  programs.mercurial = {
    enable = true;
    package = pkgs.mercurialFull;
    inherit (config.programs.git) userName userEmail;
  };
}
