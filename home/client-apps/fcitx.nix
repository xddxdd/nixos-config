{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  makeDict = name: dicts: let
    body = builtins.toJSON {
      inherit name;
      version = "1.0";
      sort = "by_weight";
      use_preset_vocabulary = false;
      import_tables = dicts;
    };
  in ''
    # Rime dictionary
    # encoding: utf-8

    ---
    ${body}

    ...
  '';
in {
  xdg.dataFile = {
    "fcitx5/themes".source = "${pkgs.fcitx5-breeze}/share/fcitx5/themes";
    "fcitx5/rime/default.custom.yaml".text = builtins.toJSON {
      patch = {
        # 雾凇拼音
        __include = "rime_ice_suggestion:/";

        # 极光拼音
        # "switcher/save_options" = ["full_shape" "ascii_punct" "simplification" "extended_charset"];

        schema_list = [{schema = "rime_ice";}];
        "menu/page_size" = 9;
        "ascii_composer/good_old_caps_lock" = true;
        "ascii_composer/switch_key" = {
          "Caps_Lock" = "noop";
          "Shift_L" = "commit_code";
          "Shift_R" = "commit_code";
          "Control_L" = "noop";
          "Control_R" = "noop";
        };
        "switcher/hotkeys" = ["F4"];
        "switcher/fold_options" = false;
        "switcher/abbreviate_options" = false;
        key_binder = {
          bindings = [
            {
              when = "composing";
              accept = "Shift+Tab";
              send = "Shift+Left";
            }
            {
              when = "composing";
              accept = "Tab";
              send = "Shift+Right";
            }
            {
              when = "composing";
              accept = "Alt+Left";
              send = "Shift+Left";
            }
            {
              when = "composing";
              accept = "Alt+Right";
              send = "Shift+Right";
            }
            {
              when = "has_menu";
              accept = "minus";
              send = "Page_Up";
            }
            {
              when = "has_menu";
              accept = "equal";
              send = "Page_Down";
            }
            {
              when = "paging";
              accept = "comma";
              send = "Page_Up";
            }
            {
              when = "has_menu";
              accept = "period";
              send = "Page_Down";
            }
            {
              when = "paging";
              accept = "bracketleft";
              send = "Page_Up";
            }
            {
              when = "has_menu";
              accept = "bracketright";
              send = "Page_Down";
            }
          ];
        };
      };
    };

    # 极光拼音
    "fcitx5/rime/aurora_pinyin.custom.yaml".text = builtins.toJSON {
      patch = {
        "switches/@0/reset" = 1;
        "translator/dictionary" = "lantian_aurora_pinyin";
        "__include" = "emoji_suggestion:/patch";
        punctuator = {
          import_preset = "symbols";
          half_shape = {
            "#" = "#";
            "*" = "*";
            "~" = "~";
            "=" = "=";
            "`" = "`";
          };
        };
      };
    };

    "fcitx5/rime/lantian_aurora_pinyin.dict.yaml".text =
      makeDict
      "lantian_aurora_pinyin"
      [
        "aurora_pinyin"
        "moegirl"
        "zhwiki"
      ];

    # 雾凇拼音
    "fcitx5/rime/rime_ice.custom.yaml".text = builtins.toJSON {
      patch = {
        "switches/@0/reset" = 1;
        "translator/dictionary" = "lantian_rime_ice";
      };
    };

    "fcitx5/rime/lantian_rime_ice.dict.yaml".text =
      makeDict
      "lantian_rime_ice"
      [
        "cn_dicts/8105"
        "cn_dicts/41448"
        "cn_dicts/base"
        "cn_dicts/ext"
        "cn_dicts/tencent"
        "cn_dicts/others"

        "moegirl"
        "zhwiki"
      ];

    # 朙月拼音
    "fcitx5/rime/luna_pinyin_simp.custom.yaml".text = builtins.toJSON {
      patch = {
        "switches/@0/reset" = 1;
        "translator/dictionary" = "lantian_luna_pinyin_simp";
        "__include" = "emoji_suggestion:/patch";
        punctuator = {
          import_preset = "symbols";
          half_shape = {
            "#" = "#";
            "*" = "*";
            "~" = "~";
            "=" = "=";
            "`" = "`";
          };
        };
      };
    };

    "fcitx5/rime/lantian_luna_pinyin_simp.dict.yaml".text =
      makeDict
      "lantian_luna_pinyin_simp"
      [
        "pinyin_simp"
        # "moegirl"
        # "zhwiki"
        "luna_pinyin.anime"
        "luna_pinyin.basis"
        "luna_pinyin.biaoqing"
        "luna_pinyin.chat"
        "luna_pinyin.classical"
        # "luna_pinyin.cn_en"
        "luna_pinyin.computer"
        "luna_pinyin.daily"
        "luna_pinyin.diet"
        "luna_pinyin.game"
        "luna_pinyin.gd"
        "luna_pinyin.hanyu"
        "luna_pinyin.history"
        "luna_pinyin.idiom"
        "luna_pinyin.moba"
        "luna_pinyin.movie"
        "luna_pinyin.music"
        "luna_pinyin.name"
        "luna_pinyin.net"
        "luna_pinyin.poetry"
        "luna_pinyin.practical"
        "luna_pinyin.sougou"
        "luna_pinyin.website"
      ];
  };
}
