{ pkgs, lib, ... }:
{
  xdg.dataFile = {
    "fcitx5/themes".source = "${pkgs.nur-xddxdd.fcitx5-breeze}/share/fcitx5/themes";
  };

  # Apply IME fix wrapper
  home.packages =
    builtins.map
      (
        p:
        lib.hiPrio (
          pkgs.runCommand "${p.name}-wrapped" { nativeBuildInputs = with pkgs; [ makeWrapper ]; } ''
            mkdir -p $out/bin
            makeWrapper \
              ${p}/bin/${p.meta.mainProgram} \
              $out/bin/${p.meta.mainProgram} \
              --set GTK_IM_MODULE wayland \
              --set QT_IM_MODULE fcitx
          ''
        )
      )
      [
        pkgs.audacious
        pkgs.ghostty
      ];
}
