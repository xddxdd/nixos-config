_:
let
  filenames = [
    "wine-extension-chm.desktop"
    "wine-extension-hlp.desktop"
    "wine-extension-htm.desktop"
    "wine-extension-html.desktop"
    "wine-extension-ini.desktop"
    "wine-extension-msp.desktop"
    "wine-extension-pdf.desktop"
    "wine-extension-rtf.desktop"
    "wine-extension-txt.desktop"
    "wine-extension-vbs.desktop"
    "wine-extension-wri.desktop"
    "wine-extension-xml.desktop"
  ];
in
{
  home.activation.block-wine-desktop-entries = builtins.concatStringsSep "\n" (
    builtins.map (f: ''
      mkdir -p "$HOME/.local/share/applications"
      rm -f "$HOME/.local/share/applications/${f}"
      touch "$HOME/.local/share/applications/${f}"
      chmod 000 "$HOME/.local/share/applications/${f}"
    '') filenames
  );
}
