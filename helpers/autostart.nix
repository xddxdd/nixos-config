{ config, pkgs, ... }:

l: builtins.listToAttrs (builtins.map ({ name, command }: {
  name = "autostart/${name}.desktop";
  value = {
    text = ''
      [Desktop Entry]
      Name=${name}
      Exec=${command}
      Type=Application
      X-KDE-autostart-after=panel
    '';
  };
}) l)
