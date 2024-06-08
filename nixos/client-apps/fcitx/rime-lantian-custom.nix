{
  lib,
  linkFarm,
  writeText,
  ...
}:
let
  makeDict =
    name: dicts:
    let
      body = builtins.toJSON {
        inherit name;
        version = "1.0";
        sort = "by_weight";
        use_preset_vocabulary = false;
        import_tables = dicts;
      };
    in
    ''
      # Rime dictionary
      # encoding: utf-8

      ---
      ${body}

      ...
    '';
in
linkFarm "rime-lantian-custom" (
  lib.mapAttrs writeText {
    "share/rime-data/default.custom.yaml" = builtins.toJSON {
      patch = {
        # 雾凇拼音
        __include = "rime_ice_suggestion:/";
        "switcher/save_options" = [ ];

        # 极光拼音
        # "switcher/save_options" = ["full_shape" "ascii_punct" "simplification" "extended_charset"];

        schema_list = [ { schema = "rime_ice"; } ];
        "menu/page_size" = 9;
        "ascii_composer/good_old_caps_lock" = true;
        "ascii_composer/switch_key" = {
          "Caps_Lock" = "noop";
          "Shift_L" = "commit_code";
          "Shift_R" = "commit_code";
          "Control_L" = "noop";
          "Control_R" = "noop";
        };
        "switcher/hotkeys" = [ "F4" ];
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
    "share/rime-data/aurora_pinyin.custom.yaml" = builtins.toJSON {
      patch = {
        "switches" = [
          {
            name = "ascii_mode";
            reset = 1;
          }
        ];
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

    "share/rime-data/lantian_aurora_pinyin.dict.yaml" = makeDict "lantian_aurora_pinyin" [
      "aurora_pinyin"
      "CustomPinyinDictionary"
      "moegirl"
      "zhwiki"
    ];

    # 雾凇拼音
    "share/rime-data/rime_ice.custom.yaml" = builtins.toJSON {
      patch = {
        "switches" = [
          {
            name = "ascii_mode";
            reset = 1;
          }
          {
            name = "traditionalization";
            reset = 0;
          }
        ];
        "translator/dictionary" = "lantian_rime_ice";
      };
    };

    "share/rime-data/lantian_rime_ice.dict.yaml" = makeDict "lantian_rime_ice" [
      "cn_dicts/8105"
      "cn_dicts/41448"
      "cn_dicts/base"
      "cn_dicts/ext"
      "cn_dicts/tencent"
      "cn_dicts/others"

      "CustomPinyinDictionary"
      "moegirl"
      "zhwiki"
    ];

    # 朙月拼音
    "share/rime-data/luna_pinyin_simp.custom.yaml" = builtins.toJSON {
      patch = {
        "switches" = [
          {
            name = "ascii_mode";
            reset = 1;
          }
          {
            name = "zh_simp";
            reset = 1;
          }
        ];
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

    "share/rime-data/lantian_luna_pinyin_simp.dict.yaml" = makeDict "lantian_luna_pinyin_simp" [
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
  }
)
