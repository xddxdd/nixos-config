{ pkgs, lib, ... }:
let
  mkWaylandIM = builtins.map (
    p:
    lib.hiPrio (
      pkgs.runCommand "${p.name}-wrapped" { nativeBuildInputs = with pkgs; [ makeWrapper ]; } ''
        mkdir -p $out/bin
        makeWrapper \
          ${p}/bin/${p.meta.mainProgram or p.pname} \
          $out/bin/${p.meta.mainProgram or p.pname} \
          --set GTK_IM_MODULE wayland \
          --set QT_IM_MODULE fcitx
      ''
    )
  );
  mkFcitxIM = builtins.map (
    p:
    lib.hiPrio (
      pkgs.runCommand "${p.name}-wrapped" { nativeBuildInputs = with pkgs; [ makeWrapper ]; } ''
        mkdir -p $out/bin
        makeWrapper \
          ${p}/bin/${p.meta.mainProgram or p.pname} \
          $out/bin/${p.meta.mainProgram or p.pname} \
          --set GTK_IM_MODULE fcitx \
          --set QT_IM_MODULE fcitx
      ''
    )
  );
in
{
  xdg.dataFile = {
    "fcitx5/themes".source = "${pkgs.nur-xddxdd.fcitx5-breeze}/share/fcitx5/themes";
  };

  # Apply IME fix wrapper
  home.packages =
    (mkWaylandIM [
      pkgs.audacious
      pkgs.ghostty
    ])
    ++ (mkFcitxIM [
      pkgs.cherry-studio
    ]);
}
