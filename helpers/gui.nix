{ config, pkgs, lib, ... }:

{
  autostart = l: builtins.listToAttrs (builtins.map
    ({ name, command }: {
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
    })
    l);

  resizeIcon = size: src: pkgs.runCommand "icon-${builtins.toString size}.png" { } ''
    ${pkgs.imagemagick}/bin/convert ${src} \
      -resize ${builtins.toString size}x${builtins.toString size}! \
      $out
  '';
}

