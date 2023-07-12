{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  fcitx5-rime-with-addons = pkgs.fcitx5-rime.override {
    librime = pkgs.lantianCustomized.librime-with-plugins;
    rimeDataPkgs = with pkgs; [
      rime-aurora-pinyin
      rime-data
      rime-dict
      rime-ice
      rime-moegirl
      rime-zhwiki
    ];
  };
in {
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons
      fcitx5-gtk
      fcitx5-rime-with-addons
      libsForQt5.fcitx5-qt
    ];
  };

  # Extra variables not covered by NixOS fcitx module
  environment.variables = {
    INPUT_METHOD = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
