{ config, pkgs, lib, ... }:

l: builtins.listToAttrs (builtins.map
  ({ name, command }:
    let
      startScript = pkgs.writeShellScript "start.sh" ''
        sleep 5
        ${command}
      '';
    in
    {
      name = "autostart/${name}.desktop";
      value = {
        text = ''
          [Desktop Entry]
          Name=${name}
          Exec=${startScript}
          Type=Application
          X-KDE-autostart-after=panel
          X-KDE-autostart-phase=2
        '';
      };
    })
  l)
