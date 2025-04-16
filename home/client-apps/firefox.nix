{ pkgs, ... }:
let
  userChrome = pkgs.writeText "userChrome.css" ''
    .titlebar-spacer {
      display: none !important;
    }
  '';
in
{
  home.activation.setup-firefox-userchrome-css = ''
    if [ -f "$HOME/.mozilla/firefox/profiles.ini" ]; then
      for F in $(cat "$HOME/.mozilla/firefox/profiles.ini" | grep Path | cut -d= -f2); do
        if [ -d "$HOME/.mozilla/firefox/$F" ]; then
          ${pkgs.coreutils}/bin/install -Dm755 ${userChrome} "$HOME/.mozilla/firefox/$F/chrome/userChrome.css"
        fi
      done
    fi
  '';
}
