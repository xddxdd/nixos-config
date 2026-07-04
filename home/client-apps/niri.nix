{
  inputs,
  pkgs,
  LT,
  osConfig,
  ...
}:
{
  imports = [
    inputs.niri-flake.homeModules.config
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.dms-plugin-registry.homeModules.default
  ];

  programs.dank-material-shell = {
    enable = true;
    niri = {
      enableKeybinds = false;
      enableSpawn = false;
      includes = {
        enable = true;
        override = true;
        originalFileName = "niri-nixos";
        filesToInclude = [ "outputs" ];
      };
    };

    plugins = {
      emojiLauncher.enable = true;
      calculator.enable = true;
      niriWindows.enable = true;
      worldClock.enable = true;
      nixPackageRunner.enable = true;
      vscodeLauncher.enable = true;
    };

    settings = {
      "currentThemeName" = "dynamic";
      "currentThemeCategory" = "dynamic";
      "customThemeFile" = "";
      "registryThemeVariants" = { };
      "matugenScheme" = "scheme-vibrant";
      "runUserMatugenTemplates" = false;
      "matugenTargetMonitor" = "";
      "popupTransparency" = 1;
      "dockTransparency" = 1;
      "widgetBackgroundColor" = "sch";
      "widgetColorMode" = "default";
      "controlCenterTileColorMode" = "primary";
      "buttonColorMode" = "primary";
      "cornerRadius" = 0;
      "niriLayoutGapsOverride" = -1;
      "niriLayoutRadiusOverride" = -1;
      "niriLayoutBorderSize" = -1;
      "hyprlandLayoutGapsOverride" = -1;
      "hyprlandLayoutRadiusOverride" = -1;
      "hyprlandLayoutBorderSize" = -1;
      "mangoLayoutGapsOverride" = -1;
      "mangoLayoutRadiusOverride" = -1;
      "mangoLayoutBorderSize" = -1;
      "use24HourClock" = false;
      "showSeconds" = true;
      "padHours12Hour" = true;
      "useFahrenheit" = false;
      "windSpeedUnit" = "kmh";
      "nightModeEnabled" = false;
      "animationSpeed" = 1;
      "customAnimationDuration" = 122;
      "syncComponentAnimationSpeeds" = true;
      "popoutAnimationSpeed" = 1;
      "popoutCustomAnimationDuration" = 150;
      "modalAnimationSpeed" = 1;
      "modalCustomAnimationDuration" = 150;
      "enableRippleEffects" = true;
      "blurEnabled" = false;
      "wallpaperFillMode" = "Fill";
      "showLauncherButton" = true;
      "showWorkspaceSwitcher" = true;
      "showFocusedWindow" = true;
      "showWeather" = true;
      "showMusic" = true;
      "showClipboard" = true;
      "showCpuUsage" = true;
      "showMemUsage" = true;
      "showCpuTemp" = true;
      "showGpuTemp" = true;
      "selectedGpuIndex" = 0;
      "enabledGpuPciIds" = [ ];
      "showSystemTray" = true;
      "systemTrayIconTintMode" = "none";
      "systemTrayIconTintSaturation" = 50;
      "systemTrayIconTintStrength" = 135;
      "showClock" = true;
      "showNotificationButton" = true;
      "showBattery" = true;
      "showControlCenterButton" = true;
      "showCapsLockIndicator" = true;
      "controlCenterShowNetworkIcon" = true;
      "controlCenterShowBluetoothIcon" = true;
      "controlCenterShowAudioIcon" = true;
      "controlCenterShowAudioPercent" = false;
      "controlCenterShowVpnIcon" = true;
      "controlCenterShowBrightnessIcon" = false;
      "controlCenterShowBrightnessPercent" = false;
      "controlCenterShowMicIcon" = false;
      "controlCenterShowMicPercent" = true;
      "controlCenterShowBatteryIcon" = false;
      "controlCenterShowPrinterIcon" = false;
      "controlCenterShowScreenSharingIcon" = true;
      "showPrivacyButton" = true;
      "privacyShowMicIcon" = false;
      "privacyShowCameraIcon" = false;
      "privacyShowScreenShareIcon" = false;
      "controlCenterWidgets" = [
        {
          "id" = "volumeSlider";
          "enabled" = true;
          "width" = 50;
        }
        {
          "id" = "brightnessSlider";
          "enabled" = true;
          "width" = 50;
        }
        {
          "id" = "wifi";
          "enabled" = true;
          "width" = 50;
        }
        {
          "id" = "bluetooth";
          "enabled" = true;
          "width" = 50;
        }
        {
          "id" = "audioOutput";
          "enabled" = true;
          "width" = 50;
        }
        {
          "id" = "audioInput";
          "enabled" = true;
          "width" = 50;
        }
        {
          "id" = "nightMode";
          "enabled" = true;
          "width" = 50;
        }
        {
          "id" = "darkMode";
          "enabled" = true;
          "width" = 50;
        }
      ];
      "showWorkspaceIndex" = true;
      "showWorkspaceName" = false;
      "showWorkspacePadding" = false;
      "workspaceScrolling" = false;
      "showWorkspaceApps" = false;
      "workspaceDragReorder" = true;
      "maxWorkspaceIcons" = 3;
      "workspaceAppIconSizeOffset" = 0;
      "groupWorkspaceApps" = true;
      "workspaceFollowFocus" = false;
      "showOccupiedWorkspacesOnly" = false;
      "reverseScrolling" = false;
      "dwlShowAllTags" = false;
      "workspaceColorMode" = "default";
      "workspaceOccupiedColorMode" = "none";
      "workspaceUnfocusedColorMode" = "default";
      "workspaceUrgentColorMode" = "default";
      "workspaceFocusedBorderEnabled" = false;
      "workspaceNameIcons" = { };
      "waveProgressEnabled" = true;
      "scrollTitleEnabled" = false;
      "audioVisualizerEnabled" = true;
      "audioScrollMode" = "nothing";
      "audioWheelScrollAmount" = 5;
      "clockCompactMode" = false;
      "focusedWindowCompactMode" = false;
      "runningAppsCompactMode" = true;
      "barMaxVisibleApps" = 0;
      "barMaxVisibleRunningApps" = 0;
      "barShowOverflowBadge" = true;
      "appsDockHideIndicators" = false;
      "appsDockColorizeActive" = false;
      "appsDockActiveColorMode" = "primary";
      "appsDockEnlargeOnHover" = false;
      "appsDockEnlargePercentage" = 125;
      "appsDockIconSizePercentage" = 100;
      "keyboardLayoutNameCompactMode" = false;
      "runningAppsCurrentWorkspace" = true;
      "runningAppsGroupByApp" = false;
      "runningAppsCurrentMonitor" = false;
      "appIdSubstitutions" = [ ];
      "centeringMode" = "index";
      "clockDateFormat" = "yyyy-MM-dd";
      "lockDateFormat" = "yyyy-MM-dd";
      "greeterRememberLastSession" = true;
      "greeterRememberLastUser" = true;
      "greeterEnableFprint" = false;
      "greeterEnableU2f" = false;
      "greeterWallpaperPath" = "";
      "mediaSize" = 1;
      "appLauncherViewMode" = "list";
      "spotlightModalViewMode" = "list";
      "browserPickerViewMode" = "grid";
      "browserUsageHistory" = { };
      "appPickerViewMode" = "grid";
      "filePickerUsageHistory" = { };
      "sortAppsAlphabetically" = true;
      "appLauncherGridColumns" = 4;
      "spotlightCloseNiriOverview" = true;
      "spotlightSectionViewModes" = { };
      "appDrawerSectionViewModes" = { };
      "niriOverviewOverlayEnabled" = true;
      "dankLauncherV2Size" = "compact";
      "dankLauncherV2BorderEnabled" = false;
      "dankLauncherV2ShowFooter" = true;
      "dankLauncherV2UnloadOnClose" = false;
      "useAutoLocation" = false;
      "weatherEnabled" = true;
      "networkPreference" = "auto";
      "iconTheme" = "System Default";
      "cursorSettings" = {
        "theme" = osConfig.stylix.cursor.name;
        "size" = osConfig.stylix.cursor.size;
        "niri" = {
          "hideWhenTyping" = false;
          "hideAfterInactiveMs" = 0;
        };
        "hyprland" = {
          "hideOnKeyPress" = false;
          "hideOnTouch" = false;
          "inactiveTimeout" = 0;
        };
        "dwl" = {
          "cursorHideTimeout" = 0;
        };
      };
      "launcherLogoMode" = "os";
      "launcherLogoCustomPath" = "";
      "launcherLogoColorOverride" = "";
      "launcherLogoColorInvertOnMode" = false;
      "launcherLogoBrightness" = 0.5;
      "launcherLogoContrast" = 1;
      "launcherLogoSizeOffset" = 0;
      "fontFamily" = "Ubuntu";
      "monoFontFamily" = "Fira Code";
      "fontWeight" = 400;
      "fontScale" = 1;
      "notepadUseMonospace" = true;
      "notepadFontFamily" = "";
      "notepadFontSize" = 14;
      "notepadShowLineNumbers" = false;
      "notepadTransparencyOverride" = -1;
      "notepadLastCustomTransparency" = 0.7;
      "soundsEnabled" = false;
      "acMonitorTimeout" = 0;
      "acLockTimeout" = 0;
      "acSuspendTimeout" = 0;
      "acSuspendBehavior" = 0;
      "acProfileName" = "";
      "batteryMonitorTimeout" = 0;
      "batteryLockTimeout" = 0;
      "batterySuspendTimeout" = 0;
      "batterySuspendBehavior" = 0;
      "batteryProfileName" = "";
      "batteryChargeLimit" = 100;
      "lockBeforeSuspend" = false;
      "loginctlLockIntegration" = true;
      "fadeToLockEnabled" = true;
      "fadeToLockGracePeriod" = 5;
      "fadeToDpmsEnabled" = true;
      "fadeToDpmsGracePeriod" = 5;
      "launchPrefix" = "";
      "brightnessDevicePins" = { };
      "wifiNetworkPins" = { };
      "bluetoothDevicePins" = { };
      "audioInputDevicePins" = { };
      "audioOutputDevicePins" = { };
      "gtkThemingEnabled" = false;
      "qtThemingEnabled" = false;
      "syncModeWithPortal" = true;
      "terminalsAlwaysDark" = false;
      "muxType" = "tmux";
      "muxUseCustomCommand" = false;
      "muxSessionFilter" = "";
      "runDmsMatugenTemplates" = false;
      "showDock" = false;
      "notificationOverlayEnabled" = false;
      "notificationPopupShadowEnabled" = true;
      "notificationPopupPrivacyMode" = false;
      "modalDarkenBackground" = true;
      "lockScreenShowPowerActions" = true;
      "lockScreenShowSystemIcons" = true;
      "lockScreenShowTime" = true;
      "lockScreenShowDate" = true;
      "lockScreenShowProfileImage" = true;
      "lockScreenShowPasswordField" = true;
      "lockScreenShowMediaPlayer" = true;
      "lockScreenPowerOffMonitorsOnLock" = false;
      "lockAtStartup" = false;
      "enableFprint" = false;
      "enableU2f" = false;
      "lockScreenActiveMonitor" = "all";
      "lockScreenInactiveColor" = "#000000";
      "lockScreenNotificationMode" = 0;
      "hideBrightnessSlider" = false;
      "notificationTimeoutLow" = 5000;
      "notificationTimeoutNormal" = 5000;
      "notificationTimeoutCritical" = 0;
      "notificationCompactMode" = false;
      "notificationPopupPosition" = 0;
      "notificationAnimationSpeed" = 1;
      "notificationCustomAnimationDuration" = 400;
      "notificationHistoryEnabled" = true;
      "notificationHistoryMaxCount" = 50;
      "notificationHistoryMaxAgeDays" = 7;
      "notificationHistorySaveLow" = true;
      "notificationHistorySaveNormal" = true;
      "notificationHistorySaveCritical" = true;
      "notificationRules" = [ ];
      "osdAlwaysShowValue" = false;
      "osdPosition" = 5;
      "osdVolumeEnabled" = true;
      "osdMediaVolumeEnabled" = true;
      "osdMediaPlaybackEnabled" = false;
      "osdBrightnessEnabled" = true;
      "osdIdleInhibitorEnabled" = true;
      "osdMicMuteEnabled" = true;
      "osdCapsLockEnabled" = true;
      "osdPowerProfileEnabled" = true;
      "osdAudioOutputEnabled" = true;
      "powerActionConfirm" = true;
      "powerActionHoldDuration" = 0.5;
      "powerMenuActions" = [
        "reboot"
        "logout"
        "poweroff"
        "suspend"
        "restart"
      ];
      "powerMenuDefaultAction" = "logout";
      "powerMenuGridLayout" = false;
      "customPowerActionLock" = "";
      "customPowerActionLogout" = "";
      "customPowerActionSuspend" = "";
      "customPowerActionHibernate" = "";
      "customPowerActionReboot" = "";
      "customPowerActionPowerOff" = "";
      "updaterHideWidget" = false;
      "updaterUseCustomCommand" = false;
      "updaterTerminalAdditionalParams" = "";
      "displayNameMode" = "system";
      "screenPreferences" = { };
      "showOnLastDisplay" = { };
      "niriOutputSettings" = { };
      "hyprlandOutputSettings" = { };
      "displayProfiles" = { };
      "activeDisplayProfile" = { };
      "displayProfileAutoSelect" = false;
      "displayShowDisconnected" = false;
      "displaySnapToEdge" = true;
      "barConfigs" = [
        {
          "id" = "default";
          "name" = "Main Bar";
          "enabled" = true;
          "position" = 0;
          "screenPreferences" = [
            "all"
          ];
          "showOnLastDisplay" = true;
          "leftWidgets" = [
            {
              "id" = "launcherButton";
              "enabled" = true;
            }
            {
              "id" = "appsDock";
              "enabled" = true;
            }
          ];
          "centerWidgets" = [ ];
          "rightWidgets" = [
            "music"
            "systemTray"
            "weather"
            "clipboard"
            "cpuUsage"
            "memUsage"
            "notificationButton"
            "battery"
            "controlCenterButton"
            "clock"
          ];
          "spacing" = 0;
          "innerPadding" = 10;
          "bottomGap" = 0;
          "transparency" = 1;
          "widgetTransparency" = 1;
          "squareCorners" = true;
          "noBackground" = false;
          "maximizeWidgetIcons" = false;
          "maximizeWidgetText" = false;
          "removeWidgetPadding" = false;
          "widgetPadding" = 8;
          "gothCornersEnabled" = false;
          "borderEnabled" = false;
          "widgetOutlineEnabled" = false;
          "fontScale" = 1.2;
          "iconScale" = 1.2;
          "autoHide" = false;
          "autoHideDelay" = 250;
          "showOnWindowsOpen" = false;
          "openOnOverview" = false;
          "visible" = true;
          "popupGapsAuto" = true;
          "popupGapsManual" = 4;
          "maximizeDetection" = true;
          "scrollEnabled" = true;
          "scrollXBehavior" = "column";
          "scrollYBehavior" = "column";
          "shadowIntensity" = 0;
          "shadowOpacity" = 60;
          "shadowColorMode" = "text";
          "shadowCustomColor" = "#000000";
          "clickThrough" = false;
        }
      ];
      "desktopClockEnabled" = false;
      "systemMonitorEnabled" = false;
      "desktopWidgetPositions" = { };
      "desktopWidgetGridSettings" = { };
      "desktopWidgetInstances" = [ ];
      "desktopWidgetGroups" = [ ];
      "builtInPluginSettings" = {
        "dms_settings_search" = {
          "trigger" = "?";
        };
      };
      "clipboardEnterToPaste" = false;
      "launcherPluginVisibility" = {
        "dms_settings_search" = {
          "allowWithoutTrigger" = true;
        };
      };
      "launcherPluginOrder" = [ ];
      "configVersion" = 5;
    };

    session = {
      "isLightMode" = false;
      "doNotDisturb" = false;
      "wallpaperPath" = ../../helpers/wallpaper/wallpaper.jpg;
      "perMonitorWallpaper" = false;
      "perModeWallpaper" = false;
      "wallpaperTransition" = "fade";
      "includedTransitions" = [
        "fade"
        "wipe"
        "disc"
        "stripes"
        "iris bloom"
        "pixelate"
        "portal"
      ];
      "wallpaperCyclingEnabled" = false;
      "nightModeEnabled" = false;
      "nightModeTemperature" = 4500;
      "nightModeHighTemperature" = 6500;
      "nightModeAutoEnabled" = false;
      "nightModeAutoMode" = "time";
      "nightModeStartHour" = 18;
      "nightModeStartMinute" = 0;
      "nightModeEndHour" = 6;
      "nightModeEndMinute" = 0;
      "latitude" = 0;
      "longitude" = 0;
      "nightModeUseIPLocation" = false;
      "nightModeLocationProvider" = "";
      "themeModeAutoEnabled" = false;
      "themeModeAutoMode" = "time";
      "themeModeStartHour" = 18;
      "themeModeStartMinute" = 0;
      "themeModeEndHour" = 6;
      "themeModeEndMinute" = 0;
      "themeModeShareGammaSettings" = true;
      "weatherLocation" = "${LT.this.city.name}, ${LT.this.city.admin1}";
      "weatherCoordinates" = "${toString LT.this.city.lat},${toString LT.this.city.lng}";
      "barPinnedApps" = [
        "firefox"
        "org.gnome.Nautilus"
        "com.mitchellh.ghostty"
        "audacious"
      ];
      "dockLauncherPosition" = 0;
      "hiddenTrayIds" = [ ];
      "trayItemOrder" = [ ];
      "recentColors" = [ ];
      "showThirdPartyPlugins" = false;
      "launchPrefix" = "";
      "lastBrightnessDevice" = "";
      "brightnessExponentialDevices" = { };
      "brightnessUserSetValues" = { };
      "brightnessExponentValues" = { };
      "selectedGpuIndex" = 0;
      "nvidiaGpuTempEnabled" = false;
      "nonNvidiaGpuTempEnabled" = false;
      "enabledGpuPciIds" = [ ];
      "wifiDeviceOverride" = "";
      "weatherHourlyDetailed" = true;
      "hiddenApps" = [ ];
      "appOverrides" = { };
      "searchAppActions" = true;
      "vpnLastConnected" = "";
      "deviceMaxVolumes" = { };
      "hiddenOutputDeviceNames" = [ ];
      "hiddenInputDeviceNames" = [ ];
      "launcherLastMode" = "all";
      "appDrawerLastMode" = "all";
      "niriOverviewLastMode" = "apps";
      "configVersion" = 3;
    };
  };

  programs.niri = {
    package = pkgs.niri;
    settings = {
      input = {
        keyboard.numlock = true;
        touchpad = {
          accel-speed = 0.4;
          accel-profile = "flat";
        };
      };

      hotkey-overlay.skip-at-startup = true;

      layout = {
        gaps = 8;
        center-focused-column = "never";

        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        default-column-width.proportion = 0.5;

        focus-ring.enable = false;
        border.enable = false;
        shadow.enable = false;
      };

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      gestures.hot-corners.enable = false;

      binds = {
        "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

        "Mod+T" = {
          action.spawn = "ghostty";
          hotkey-overlay.title = "Open a Terminal: ghostty";
        };

        "XF86AudioRaiseVolume" = {
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
          allow-when-locked = true;
        };
        "XF86AudioLowerVolume" = {
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          allow-when-locked = true;
        };
        "XF86AudioMute" = {
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          allow-when-locked = true;
        };
        "XF86AudioMicMute" = {
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          allow-when-locked = true;
        };

        "XF86AudioPlay" = {
          action.spawn-sh = "playerctl play-pause";
          allow-when-locked = true;
        };
        "XF86AudioStop" = {
          action.spawn-sh = "playerctl stop";
          allow-when-locked = true;
        };
        "XF86AudioPrev" = {
          action.spawn-sh = "playerctl previous";
          allow-when-locked = true;
        };
        "XF86AudioNext" = {
          action.spawn-sh = "playerctl next";
          allow-when-locked = true;
        };

        "XF86MonBrightnessUp" = {
          action.spawn = [
            "brightnessctl"
            "--class=backlight"
            "set"
            "+10%"
          ];
          allow-when-locked = true;
        };
        "XF86MonBrightnessDown" = {
          action.spawn = [
            "brightnessctl"
            "--class=backlight"
            "set"
            "10%-"
          ];
          allow-when-locked = true;
        };

        "Mod+O" = {
          action.toggle-overview = [ ];
          repeat = false;
        };
        "Mod+Q" = {
          action.close-window = [ ];
          repeat = false;
        };
        "Alt+F4" = {
          action.close-window = [ ];
          repeat = false;
        };

        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Down".action.focus-window-down = [ ];
        "Mod+Up".action.focus-window-up = [ ];
        "Mod+Right".action.focus-column-right = [ ];

        "Mod+Ctrl+Left".action.move-column-left = [ ];
        "Mod+Ctrl+Down".action.move-window-down = [ ];
        "Mod+Ctrl+Up".action.move-window-up = [ ];
        "Mod+Ctrl+Right".action.move-column-right = [ ];

        "Mod+Home".action.focus-column-first = [ ];
        "Mod+End".action.focus-column-last = [ ];
        "Mod+Ctrl+Home".action.move-column-to-first = [ ];
        "Mod+Ctrl+End".action.move-column-to-last = [ ];

        "Mod+Shift+Left".action.focus-monitor-left = [ ];
        "Mod+Shift+Down".action.focus-monitor-down = [ ];
        "Mod+Shift+Up".action.focus-monitor-up = [ ];
        "Mod+Shift+Right".action.focus-monitor-right = [ ];

        "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
        "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
        "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
        "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];

        "Mod+Page_Down".action.focus-workspace-down = [ ];
        "Mod+Page_Up".action.focus-workspace-up = [ ];
        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
        "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
        "Mod+Shift+Page_Up".action.move-workspace-up = [ ];

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+Ctrl+1".action.move-column-to-workspace = 1;
        "Mod+Ctrl+2".action.move-column-to-workspace = 2;
        "Mod+Ctrl+3".action.move-column-to-workspace = 3;
        "Mod+Ctrl+4".action.move-column-to-workspace = 4;
        "Mod+Ctrl+5".action.move-column-to-workspace = 5;
        "Mod+Ctrl+6".action.move-column-to-workspace = 6;
        "Mod+Ctrl+7".action.move-column-to-workspace = 7;
        "Mod+Ctrl+8".action.move-column-to-workspace = 8;
        "Mod+Ctrl+9".action.move-column-to-workspace = 9;

        "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
        "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

        "Mod+Comma".action.consume-window-into-column = [ ];
        "Mod+Period".action.expel-window-from-column = [ ];

        "Mod+R".action.switch-preset-column-width = [ ];
        "Mod+Shift+R".action.switch-preset-column-width-back = [ ];

        "Mod+Ctrl+Shift+R".action.switch-preset-window-height = [ ];
        "Mod+Ctrl+R".action.reset-window-height = [ ];

        "Mod+F".action.maximize-column = [ ];
        "Mod+Shift+F".action.fullscreen-window = [ ];

        "Mod+M".action.maximize-window-to-edges = [ ];

        "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];

        "Mod+C".action.center-column = [ ];
        "Mod+Ctrl+C".action.center-visible-columns = [ ];

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        "Mod+V".action.toggle-window-floating = [ ];
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

        "Mod+W".action.toggle-column-tabbed-display = [ ];

        "Print".action.screenshot = [ ];
        "Ctrl+Print".action.screenshot-screen = [ ];
        "Alt+Print".action.screenshot-window = [ ];

        "Mod+Escape" = {
          action.toggle-keyboard-shortcuts-inhibit = [ ];
          allow-inhibiting = false;
        };

        "Super+space" = {
          action.spawn = [
            "dms"
            "ipc"
            "call"
            "spotlight"
            "toggle"
          ];
          hotkey-overlay.title = "App Launcher: Toggle";
        };
      };
    };
  };
}
