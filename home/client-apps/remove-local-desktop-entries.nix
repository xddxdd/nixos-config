_: {
  home.activation.remove-local-desktop-entries = ''
    mkdir -p "$HOME/.local/share/applications"
    find "$HOME/.local/share/applications" -maxdepth 1 -type f -name '*.desktop' -delete
  '';
}
