{
  pkgs,
  lib,
  ...
}:
let
  userChrome = pkgs.writeText "userChrome.css" ''
    li.calendar-month-day-box-list-item {
      /* Make multi-day tasks continuous */
      margin: 2px 0 !important;
    }

    calendar-month-day-box-item.calendar-color-box {
      /* 2px padding + 3px background */
      background: linear-gradient(90deg, #0000 2px, var(--item-backcolor) 2px, var(--item-backcolor) 5px, #0000 5px) !important;
      border-radius: 0 !important;
      padding-left: 10px !important;
      box-shadow: none !important;
      color: light-dark(#000, #fff) !important;
    }

    calendar-month-day-box-item[allday="true"].calendar-color-box {
      /* Semi transparent background */
      background: color-mix(in srgb, var(--item-backcolor) 50%, transparent) !important;
      /* Solid border on top/bottom */
      border-top: 1px solid var(--item-backcolor) !important;
      border-bottom: 1px solid var(--item-backcolor) !important;
    }
  '';

  thunderbird-addons = pkgs.callPackage ./addons { };
in
{
  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird-bin; # Building Thunderbird from source is forbidden
    profiles."ayx6omhb.default" = {
      isDefault = true;
      extensions = with thunderbird-addons; [
        # keep-sorted start
        betterunsubscribe
        display-mail-user-agent-t
        dkim-verifier
        get-all-mail-button-for-tb78
        identity-chooser
        search-for
        simple-startup-minimizer
        ublock-origin
        # keep-sorted end
      ];
      settings."extensions.autoDisableScopes" = 0; # Auto enable installed extensions
    };
  };

  # Home Manager now owns profiles.ini, which Thunderbird generated until now
  home.file.".thunderbird/profiles.ini".force = true;

  home.activation.setup-thunderbird-userchrome-css = ''
    if [ -f "$HOME/.thunderbird/profiles.ini" ]; then
      for F in $(cat "$HOME/.thunderbird/profiles.ini" | grep Path | cut -d= -f2); do
        if [ -d "$HOME/.thunderbird/$F" ]; then
          ${lib.getExe' pkgs.coreutils "install"} -Dm755 ${userChrome} "$HOME/.thunderbird/$F/chrome/userChrome.css"
        fi
      done
    fi
  '';
}
