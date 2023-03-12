{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons
      fcitx5-gtk
      fcitx5-rime
      libsForQt5.fcitx5-qt
      rime-aurora-pinyin
      rime-data
      rime-dict
      rime-moegirl
      rime-zhwiki
    ];
  };

  # Extra variables not covered by NixOS fcitx module
  environment.variables = {
    INPUT_METHOD = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
