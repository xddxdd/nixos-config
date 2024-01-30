{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  rime-lantian-custom = pkgs.callPackage ./rime-lantian-custom.nix {};

  fcitx5-rime-with-addons =
    (pkgs.fcitx5-rime.override {
      librime = pkgs.lantianCustomized.librime-with-plugins;
      rimeDataPkgs = with pkgs; [
        rime-aurora-pinyin
        rime-data
        rime-dict
        rime-ice
        rime-lantian-custom
        rime-moegirl
        rime-zhwiki
      ];
    })
    .overrideAttrs (old: {
      # Prebuild schema data
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.parallel];
      postInstall =
        (old.postInstall or "")
        + ''
          for F in $out/share/rime-data/*.schema.yaml; do
            echo "rime_deployer --compile "$F" $out/share/rime-data $out/share/rime-data $out/share/rime-data/build" >> parallel.lst
          done
          parallel -j$(nproc) < parallel.lst || true
        '';
    });
in {
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-gtk
        fcitx5-rime-with-addons
        libsForQt5.fcitx5-qt
      ];
    };
  };

  # Extra variables not covered by NixOS fcitx module
  environment.variables = lib.mkIf (!config.i18n.inputMethod.fcitx5.waylandFrontend) {
    INPUT_METHOD = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
