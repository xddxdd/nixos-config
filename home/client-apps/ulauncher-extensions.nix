{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  xdg.dataFile."ulauncher/extensions".source = pkgs.linkFarm "ulauncher-extensions" {
    "com.github.dhelmr.ulauncher-tldr" = LT.sources.ulauncher-tldr.src;
    "com.github.luispabon.ulauncher-virtualbox" = LT.sources.ulauncher-virtualbox.src;
    "com.github.plibither8.ulauncher-vscode-recent" = pkgs.stdenv.mkDerivation {
      inherit (LT.sources.ulauncher-vscode-recent) pname version src;
      patches = [ ../../patches/ulauncher-vscode-recent-path.patch ];
      installPhase = ''
        mkdir -p $out/
        cp -r * $out/
      '';
    };
    "com.github.rnairn01.ulauncher-meme-my-text" = LT.sources.ulauncher-meme-my-text.src;
    "com.github.sergius02.ulauncher-colorconverter" = LT.sources.ulauncher-colorconverter.src;
    "com.github.tchar.ulauncher-albert-calculate-anything" =
      LT.sources.ulauncher-albert-calculate-anything.src;
    "com.github.ulauncher.ulauncher-emoji" = LT.sources.ulauncher-emoji.src;
  };
}
