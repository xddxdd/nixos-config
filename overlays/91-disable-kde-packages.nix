_: final: prev: {
  kdePackages = prev.kdePackages.overrideScope (
    _final: _prev: {
      ocean-sound-theme = final.emptyDirectory;
      plasma-workspace-wallpapers = final.emptyDirectory;
    }
  );
}
