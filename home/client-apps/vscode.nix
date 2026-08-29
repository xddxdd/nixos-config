{ pkgs, ... }:
{
  home.packages = [ pkgs.vscode ];

  # VSCode vibrancy plugin patched binary location
  # I patch VSCode myself so force override this
  xdg.dataFile."vscode-vibrancy".source = pkgs.linkFarm "vscode-vibrancy" {
    current = pkgs.vscode;
  };
}
