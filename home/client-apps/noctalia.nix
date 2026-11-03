{
  config,
  inputs,
  lib,
  osConfig,
  LT,
  pkgs,
  ...
}:
let
  iconScale = 1.5;
  itemSpacing = 12;
  stylixAccent = config.lib.stylix.colors.withHashtag.base0D;
in
{
  imports = [
    inputs.umbriel.homeModules.default
    inputs.noctalia.homeModules.default
  ];

  programs.umbriel = {
    enable = true;
    settings = {
      include = {
        files = [ ];
        optional.files = [ ];
      };

      appearance.blur.radius = 3;

      appearance.corner_radius = 0;
      appearance.border_width = 0;

      appearance.title_bar = {
        mode = "on";
        button_corner_radius = 0;
        button_glyph = "always";
        button_background = false;
      };

      colors.border.focused = stylixAccent;

      colors.title_bar = {
        close_glyph = stylixAccent;
        close_glyph_hover = stylixAccent;
        maximize_glyph = stylixAccent;
        maximize_glyph_hover = stylixAccent;
        minimize_glyph = stylixAccent;
        minimize_glyph_hover = stylixAccent;
      };

      output."eDP-1".scale = osConfig.lantian.hidpi or 1;

      input = {
        keyboard.numlock_toggle = true;
        touchpad = {
          tap = true;
          natural_scroll = true;
          sensitivity = 0.4;
          disable_while_typing = false;
          click_method = "clickfinger";
        };
      };

      keybinds = {
        "Alt+F4" = "window-close";
        "Alt+Tab" = "spawn noctalia msg window-switcher hold";
        "Alt+Shift+Tab" = "spawn noctalia msg window-switcher hold reverse";
        "Mod+Return" = {
          action = "spawn kitty";
          repeat = false;
        };
        "Mod" = "spawn noctalia msg panel-toggle launcher";
        "Mod+Q" = {
          action = "window-close";
          repeat = false;
        };
        "Mod+Escape" = "session-quit";
        "Mod+Shift+Escape" = {
          action = "shortcuts-inhibit-toggle";
          allow_when_inhibited = true;
          repeat = false;
        };
        "XF86AudioRaiseVolume" = {
          action = "spawn noctalia msg volume-up";
          allow_when_locked = true;
        };
        "XF86AudioLowerVolume" = {
          action = "spawn noctalia msg volume-down";
          allow_when_locked = true;
        };
        "XF86AudioMute" = {
          action = "spawn noctalia msg volume-mute";
          allow_when_locked = true;
          repeat = false;
        };
        "XF86AudioPlay" = {
          action = "spawn noctalia msg media toggle";
          allow_when_locked = true;
          repeat = false;
        };
        "XF86AudioNext" = {
          action = "spawn noctalia msg media next";
          allow_when_locked = true;
        };
        "XF86AudioPrev" = {
          action = "spawn noctalia msg media previous";
          allow_when_locked = true;
        };
        "XF86MonBrightnessUp" = {
          action = "spawn noctalia msg brightness-up";
          allow_when_locked = true;
        };
        "XF86MonBrightnessDown" = {
          action = "spawn noctalia msg brightness-down";
          allow_when_locked = true;
        };
        "Mod+Left" = "window-focus-left";
        "Mod+Down" = "window-focus-down";
        "Mod+Up" = "window-focus-up";
        "Mod+Right" = "window-focus-right";
        "Mod+H" = "window-focus-left";
        "Mod+J" = "window-focus-down";
        "Mod+K" = "window-focus-up";
        "Mod+L" = "window-focus-right";
        "Mod+F1" = "window-focus-next";
        "Mod+Shift+Left" = "column-move-left";
        "Mod+Shift+Down" = "window-move-down";
        "Mod+Shift+Up" = "window-move-up";
        "Mod+Shift+Right" = "column-move-right";
        "Mod+T" = {
          action = "window-toggle-floating";
          repeat = false;
        };
        "Mod+Shift+T" = {
          action = "window-focus-switch-floating";
          repeat = false;
        };
        "Mod+P" = {
          action = "window-toggle-pinned";
          repeat = false;
        };
        "Mod+M" = "window-toggle-maximize-to-edges";
        "Mod+F" = {
          action = "window-toggle-fullscreen";
          repeat = false;
        };
        "Mod+Ctrl+F" = "window-toggle-maximize";
        "Mod+R" = "window-cycle-primary-extent";
        "Mod+Shift+R" = "window-cycle-primary-extent-back";
        "Mod+Comma" = "window-consume-left";
        "Mod+Period" = "window-consume-right";
        "Mod+Ctrl+Comma" = "window-consume-from-left";
        "Mod+Ctrl+Period" = "window-consume-from-right";
        "Mod+W" = {
          action = "column-toggle-tabbed";
          repeat = false;
        };
        "Mod+Alt+Right" = "column-focus-tab-next";
        "Mod+Alt+Left" = "column-focus-tab-previous";
        "Mod+WheelUp" = "window-focus-left";
        "Mod+WheelDown" = "window-focus-right";
        "Mod+O" = {
          action = "overview-toggle";
          repeat = false;
        };
        "Mod+1" = "workspace-switch 1";
        "Mod+2" = "workspace-switch 2";
        "Mod+3" = "workspace-switch 3";
        "Mod+4" = "workspace-switch 4";
        "Mod+5" = "workspace-switch 5";
        "Mod+6" = "workspace-switch 6";
        "Mod+7" = "workspace-switch 7";
        "Mod+8" = "workspace-switch 8";
        "Mod+9" = "workspace-switch 9";
        "Mod+Shift+1" = "window-move-to-workspace 1";
        "Mod+Shift+2" = "window-move-to-workspace 2";
        "Mod+Shift+3" = "window-move-to-workspace 3";
        "Mod+Shift+4" = "window-move-to-workspace 4";
        "Mod+Shift+5" = "window-move-to-workspace 5";
        "Mod+Shift+6" = "window-move-to-workspace 6";
        "Mod+Shift+7" = "window-move-to-workspace 7";
        "Mod+Shift+8" = "window-move-to-workspace 8";
        "Mod+Shift+9" = "window-move-to-workspace 9";
        "Mod+Shift+Space" = {
          action = "window-move-to-scratchpad";
          repeat = false;
        };
        "Mod+Space" = "spawn noctalia msg panel-toggle launcher";
        "Mod+E" = "scratchpad-toggle";
        "Mod+Ctrl+Space" = {
          action = "window-restore-from-scratchpad";
          repeat = false;
        };
        "Mod+Tab" = "scratchpad-focus-next";
      };

      layout = {
        mode = "stacking";
        gap = 0;
        extent_presets = [
          0.333
          0.5
          0.667
        ];
        client_maximize = "edges";
        scrolling.default_extent_fraction = 0.5;
      };

      window_rule = [
        {
          match.app_id = "^org[.]gnome[.]Nautilus$";
          title_bar = "off";
        }
        {
          match.app_id = "^code$|^ghostty$|^com[.]mitchellh[.]ghostty$";
          blur = true;
        }
        {
          match.app_id = "^dev.noctalia.Noctalia$";
          default_floating = true;
          default_floating_size_px = {
            width = 1020;
            height = 900;
          };
        }
        {
          match.app_id = "^dev.noctalia.UmbrielSharePicker$";
          default_floating = true;
          default_floating_size_px = {
            width = 800;
            height = 600;
          };
        }
        {
          match.title = "^(Picture-in-Picture|Picture in picture)$";
          default_floating = true;
          default_maximize = false;
          default_position = {
            x = 20;
            y = 20;
            anchor = "bottom_right";
          };
        }
        {
          match.title = "^notificationtoasts_.+_desktop";
          default_position = {
            x = 0;
            y = 0;
            anchor = "bottom_right";
          };
          default_focused = false;
          default_pinned = true;
        }
      ];

      layer_rule = [
        {
          match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
          blur = true;
          blur_ignore_alpha = 0.5;
          blur_popups = true;
        }
        {
          match.namespace = "^noctalia-(notification|dock|panel|attached-panel|osd)$";
          blur_optimized = false;
        }
      ];

      hot_corners.top_left.enabled = false;
    };
  };

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ../../patches/noctalia-tray-item-size.patch
        ../../patches/noctalia-switcher-no-pointer-warp.patch
      ];
    });

    settings = {
      shell = {
        corner_radius_scale = 0.0;
        polkit_agent = true;
      };
      shell.panel.transparency_mode = "solid";

      audio.enable_sounds = false;

      location = {
        auto_locate = false;
        latitude = builtins.fromJSON LT.this.city.lat;
        longitude = builtins.fromJSON LT.this.city.lng;
      };
      weather.enabled = true;

      lockscreen.enabled = false;

      wallpaper = lib.optionalAttrs (osConfig.networking.hostName == "lt-hp-omen") {
        enabled = true;
        directory = "/home/lantian/Pictures/Wallpapers/轮换";
        automation = {
          enabled = true;
          interval_seconds = 300;
        };
      };

      bar.main = {
        radius = 0;
        background_opacity = 0.0;
        compositor_blur = false;
        margin_ends = 0;
        padding = 10;
        thickness = 40;
        widget_spacing = itemSpacing;
        font_scale = 1.2;
        start = [
          "launcher"
          "taskbar"
        ];
        center = [ ];
        end = [
          "tray"
          "clipboard"
          "weather"
          "battery"
          "clock"
          "notifications"
          "control-center"
        ];
      };

      widget = {
        cpu.type = "sysmon";
        ram.type = "sysmon";
        clock.format = "{:%I:%M:%S %p}";
        taskbar.icon_scale = iconScale;
        taskbar.item_spacing = itemSpacing;
        taskbar.pinned = [
          "org.gnome.Nautilus"
          "firefox"
          "com.mitchellh.ghostty"
          "audacious"
        ];
        tray.item_size = 16.0 * iconScale;
        launcher.custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake-white.png";
        launcher.scale = iconScale;
        launcher.font_scale = 1.0 / iconScale;
        weather.scale = iconScale;
        weather.font_scale = 1.0 / iconScale;
        battery.scale = iconScale;
        battery.font_scale = 1.0 / iconScale;
        notifications.scale = iconScale;
        notifications.font_scale = 1.0 / iconScale;
        control-center.scale = iconScale;
        control-center.font_scale = 1.0 / iconScale;
        clipboard.scale = iconScale;
        clipboard.font_scale = 1.0 / iconScale;
      };
    };
  };
}
