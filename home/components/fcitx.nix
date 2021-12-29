{ config, pkgs, ... }:

let
  rime-dict-files = [
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
in
{
  xdg.dataFile = {
    "fcitx5/rime/default.custom.yaml".text = builtins.toJSON {
      patch = {
        schema_list = [ ({ schema = "luna_pinyin_simp"; }) ];
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
        "switcher/save_options" = [ "full_shape" "ascii_punct" "simplification" "extended_charset" ];
        "switcher/fold_options" = false;
        "switcher/abbreviate_options" = false;
      };
    };

    "fcitx5/rime/luna_pinyin_simp.custom.yaml".text = builtins.toJSON {
      patch = {
        "switches/@0/reset" = 1;
        "translator/dictionary" = "lantian";
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

    "fcitx5/rime/lantian.dict.yaml".text =
      let
        body = builtins.toJSON {
          name = "lantian";
          version = "1.0";
          sort = "by_weight";
          use_preset_vocabulary = true;
          import_tables = [
            "luna_pinyin"
            "moegirl"
            "zhwiki"
          ] ++ rime-dict-files;
        };
      in
      ''
        # Rime dictionary
        # encoding: utf-8

        ---
        ${body}

        ...
      '';

    "fcitx5/rime/moegirl.dict.yaml".source = "${pkgs.nur.repos.xddxdd.rime-moegirl}/share/rime-data/moegirl.dict.yaml";
    "fcitx5/rime/zhwiki.dict.yaml".source = "${pkgs.nur.repos.xddxdd.rime-zhwiki}/share/rime-data/zhwiki.dict.yaml";
  } // (builtins.listToAttrs (builtins.map
    (name: pkgs.lib.nameValuePair "fcitx5/rime/${name}.dict.yaml" {
      source = "${pkgs.nur.repos.xddxdd.rime-dict}/share/rime-data/${name}.dict.yaml";
    })
    rime-dict-files));
}
