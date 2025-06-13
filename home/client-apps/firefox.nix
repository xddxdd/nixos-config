{
  pkgs,
  config,
  ...
}:
let
  userChrome = pkgs.writeText "userChrome.css" ''
    .titlebar-spacer {
      display: none !important;
    }

    ${config.programs.firefox.profiles._stylix.userChrome}
  '';

  userContent = pkgs.writeText "userContent.css" ''
    ${config.programs.firefox.profiles._stylix.userContent}
  '';
in
{
  home.activation.setup-firefox-user-config = ''
    for BASE_DIR in "$HOME/.mozilla/firefox" "$HOME/.librewolf"; do
      if [ -f "$BASE_DIR/profiles.ini" ]; then
        for F in $(cat "$BASE_DIR/profiles.ini" | grep Path | cut -d= -f2); do
          if [ -d "$BASE_DIR/$F" ]; then
            ${pkgs.coreutils}/bin/install -Dm755 ${userChrome} "$BASE_DIR/$F/chrome/userChrome.css"
            ${pkgs.coreutils}/bin/install -Dm755 ${userContent} "$BASE_DIR/$F/chrome/userContent.css"
          fi
        done
      fi
    done
  '';
}
