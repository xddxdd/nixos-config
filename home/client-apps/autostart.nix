{
  lib,
  LT,
  osConfig,
  ...
}:
{
  xdg.configFile = LT.gui.autostart (
    (lib.optionals (osConfig.networking.hostName == "lt-hp-omen") [
      # keep-sorted start
      "cherry-studio --start-minimized"
      "discord --start-minimized"
      "materialgram -autostart"
      "neochat"
      "steam -silent"
      "thunderbird"
      "vesktop --start-minimized"
      # keep-sorted end
    ])
    ++ [
      # keep-sorted start
      "gcdemu"
      # keep-sorted end
    ]
  );

  home.activation.remove-other-autostart-entries = ''
    find "$HOME/.config/autostart" -maxdepth 1 -type f -name '*.desktop' -delete
  '';
}
