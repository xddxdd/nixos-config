_: {
  autostart =
    l:
    builtins.listToAttrs (
      builtins.map (
        { name, command }:
        {
          name = "autostart/${name}.desktop";
          value = {
            text = ''
              [Desktop Entry]
              Name=${name}
              Exec=sh -c "sleep 5; exec ${command}"
              Type=Application
              X-KDE-autostart-after=panel
              X-KDE-autostart-phase=2
            '';
          };
        }
      ) l
    );
}
