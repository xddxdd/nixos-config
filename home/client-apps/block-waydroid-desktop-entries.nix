_: {
  home.activation.block-waydroid-desktop-entries = ''
    mkdir -p "$HOME/.local/share/applications"
    shopt -s nullglob
    for F in $HOME/.local/share/applications/waydroid*.desktop; do
      rm -f "$F"
      touch "$F"
      chmod 000 "$F"
    done
    shopt -u nullglob
  '';
}
