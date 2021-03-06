{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  xdg.dataFile = {
    "ulauncher/extensions/com.github.dhelmr.ulauncher-tldr".source = LT.sources.ulauncher-tldr.src;
    "ulauncher/extensions/com.github.luispabon.ulauncher-virtualbox".source = LT.sources.ulauncher-virtualbox.src;
    "ulauncher/extensions/com.github.plibither8.ulauncher-vscode-recent".source = pkgs.stdenv.mkDerivation {
      inherit (LT.sources.ulauncher-vscode-recent) pname version src;
      patches = [ ../../patches/ulauncher-vscode-recent-path.patch ];
      installPhase = ''
        mkdir -p $out/
        cp -r * $out/
      '';
    };
    "ulauncher/extensions/com.github.rnairn01.ulauncher-meme-my-text".source = LT.sources.ulauncher-meme-my-text.src;
    "ulauncher/extensions/com.github.sergius02.ulauncher-colorconverter".source = LT.sources.ulauncher-colorconverter.src;
    "ulauncher/extensions/com.github.tchar.ulauncher-albert-calculate-anything".source = LT.sources.ulauncher-albert-calculate-anything.src;
    "ulauncher/extensions/com.github.ulauncher.ulauncher-emoji".source = LT.sources.ulauncher-emoji.src;
  };
}
