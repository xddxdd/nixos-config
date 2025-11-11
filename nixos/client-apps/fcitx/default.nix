{
  pkgs,
  ...
}:
let
  rime-lantian-custom = pkgs.callPackage ./rime-lantian-custom.nix { };

  fcitx5-rime-with-addons =
    (pkgs.fcitx5-rime.override {
      librime = pkgs.nur-xddxdd.lantianCustomized.librime-with-plugins;
      rimeDataPkgs = with pkgs; [
        nur-xddxdd.rime-aurora-pinyin
        nur-xddxdd.rime-custom-pinyin-dictionary
        nur-xddxdd.rime-dict
        nur-xddxdd.rime-ice
        nur-xddxdd.rime-moegirl
        nur-xddxdd.rime-zhwiki
        rime-data
        rime-lantian-custom
      ];
    }).overrideAttrs
      (old: {
        # Prebuild schema data
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.parallel ];
        postInstall =
          (old.postInstall or "")
          + ''
            for F in $out/share/rime-data/*.schema.yaml; do
              echo "rime_deployer --compile "$F" $out/share/rime-data $out/share/rime-data $out/share/rime-data/build" >> parallel.lst
            done
            parallel -j$(nproc) < parallel.lst || true
          '';
      });
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-rime-with-addons
        kdePackages.fcitx5-chinese-addons
        kdePackages.fcitx5-qt
      ];
    };
  };
}
