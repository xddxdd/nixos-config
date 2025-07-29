{
  LT,
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  palette = lib.filterAttrs (k: v: builtins.match "base0[0-9A-F]" k != null) config.lib.stylix.colors;
  userStyles = builtins.map builtins.baseNameOf (LT.ls "${inputs.catppuccin-userstyles}/styles");
  userStyleFile = inputs.nix-userstyles.packages.${pkgs.system}.mkUserStyles palette userStyles;
in
{
  stylix.targets = {
    # Having KDE is enough, QT module only supports qtct not kde6
    qt.enable = false;

    firefox = {
      colorTheme.enable = true;
      profileNames = [ "lantian" ];
    };
    librewolf = {
      colorTheme.enable = true;
      profileNames = [ "lantian" ];
    };
  };

  programs.firefox.profiles.lantian.userContent = ''
    ${builtins.readFile "${userStyleFile}"}
  '';
}
