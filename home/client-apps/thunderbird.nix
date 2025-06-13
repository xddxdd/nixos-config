{ pkgs, config, ... }:
let
  userChrome = pkgs.writeText "userChrome.css" ''
    .titlebar-buttonbox-container {
      display:none;
    }

    ${config.programs.firefox.profiles._stylix.userChrome}
  '';

  userContent = pkgs.writeText "userContent.css" ''
    ${config.programs.firefox.profiles._stylix.userContent}
  '';
in
{
  home.activation.setup-thunderbird-userchrome-css = ''
    if [ -f "$HOME/.thunderbird/profiles.ini" ]; then
      for F in $(cat "$HOME/.thunderbird/profiles.ini" | grep Path | cut -d= -f2); do
        if [ -d "$HOME/.thunderbird/$F" ]; then
          ${pkgs.coreutils}/bin/install -Dm755 ${userChrome} "$HOME/.thunderbird/$F/chrome/userChrome.css"
          ${pkgs.coreutils}/bin/install -Dm755 ${userContent} "$HOME/.thunderbird/$F/chrome/userContent.css"
        fi
      done
    fi
  '';
}
