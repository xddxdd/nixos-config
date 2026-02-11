{
  pkgs,
  lib,
  ...
}:
let
  userChrome = pkgs.writeText "userChrome.css" ''
    .titlebar-buttonbox-container {
      display: none;
    }

    .calendar-month-day-box-list-item {
      /* Make multi-day tasks continuous */
      margin: 2px 0 !important;
    }

    .calendar-color-box {
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
in
{
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
