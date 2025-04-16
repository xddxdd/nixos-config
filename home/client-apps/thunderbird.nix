{ pkgs, ... }:
let
  userChrome = pkgs.writeText "userChrome.css" ''
    .titlebar-buttonbox-container {
      display:none;
    }
  '';
in
{
  home.activation.setup-thunderbird-userchrome-css = ''
    if [ -f "$HOME/.thunderbird/profiles.ini" ]; then
      for F in $(cat "$HOME/.thunderbird/profiles.ini" | grep Path | cut -d= -f2); do
        if [ -d "$HOME/.thunderbird/$F" ]; then
          ${pkgs.coreutils}/bin/install -Dm755 ${userChrome} "$HOME/.thunderbird/$F/chrome/userChrome.css"
        fi
      done
    fi
  '';
}
