{
  pkgs,
  LT,
  lib,
  ...
}:
let
  extensions = lib.filterAttrs (k: v: lib.hasPrefix "ulauncher-" k) LT.sources;
in
{
  xdg.dataFile."ulauncher/extensions".source = pkgs.linkFarm "ulauncher-extensions" (
    (lib.mapAttrs (n: v: v.src) extensions)
    // {
      "ulauncher-vscode-recent" = pkgs.applyPatches {
        inherit (LT.sources.ulauncher-vscode-recent) src;
        patches = [
          ../../patches/ulauncher-vscode-recent-path.patch
          ../../patches/ulauncher-vscode-exclude-nonexistent-path.patch
        ];
      };
    }
  );
}
