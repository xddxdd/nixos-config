_: {
  programs.okular = {
    enable = true;
    package = null;
    general = {
      mouseMode = "TextSelect";
      obeyDrm = false;
      openFileInTabs = true;
      showScrollbars = true;
      smoothScrolling = true;
      viewContinuous = true;
      zoomMode = "autoFit";
    };
    performance = {
      enableTransparencyEffects = true;
      memoryUsage = "Greedy";
    };
  };

  programs.plasma = {
    enable = true;
    immutableByDefault = true;
    overrideConfig = false;
    resetFiles = [
      "khotkeysrc"
      "kglobalshortcutsrc"
      "kwinrulesrc"
    ];

    desktop = {
      icons = {
        alignment = "left";
        arrangement = "topToBottom";
        folderPreviewPopups = false;
        lockInPlace = true;
        size = 3;
        sorting = {
          descending = false;
          foldersFirst = true;
          mode = "name";
        };
      };
    };

    hotkeys.commands = {
      jamesdsp-toggle = {
        command = "jamesdsp-toggle";
        comment = "Toggle JamesDSP on/off";
        key = "Launch (8)";
      };
      terminal = {
        command = "ghostty";
        comment = "Start terminal";
        key = "Launch (2)";
      };
      terminal-python = {
        command = "ghostty -e python3";
        comment = "Start terminal with Python";
        key = "Calculator";
      };
      ulauncher-toggle = {
        command = "ulauncher-toggle";
        comment = "Toggle Ulauncher search bar";
        key = "Meta+Space";
      };
      noop = {
        command = "true";
        comment = "No Operation";
        keys = [
          "Launch (0)"
          "Favorites"
          "Launch Mail"
        ];
      };
    };

    kscreenlocker = {
      autoLock = false;
      lockOnResume = false;
      lockOnStartup = false;
    };

    kwin = {
      cornerBarrier = true;
      edgeBarrier = 100;

      effects = {
        blur = {
          enable = true;
          noiseStrength = 5;
          strength = 15;
        };
        cube.enable = false;
        desktopSwitching.animation = "slide";
        dimAdminMode.enable = true;
        dimInactive.enable = false;
        fallApart.enable = false;
        fps.enable = false;
        minimization.animation = "squash";
        shakeCursor.enable = true;
        slideBack.enable = false;
        snapHelper.enable = false;
        translucency.enable = false;
        windowOpenClose.animation = "scale";
        wobblyWindows.enable = true;
      };

      nightLight.enable = false;

      titlebarButtons = {
        left = [
          "more-window-actions"
          "application-menu"
        ];
        right = [
          "minimize"
          "maximize"
          "close"
        ];
      };

      virtualDesktops = {
        number = 4;
        rows = 1;
      };
    };

    spectacle.shortcuts = {
      captureActiveWindow = "Meta+Print";
      captureCurrentMonitor = "Ctrl+Print";
      captureEntireDesktop = "Shift+Print";
      captureRectangularRegion = "Meta+Shift+Print";
      captureWindowUnderCursor = "Meta+Ctrl+Print";
      launch = "Print";
      launchWithoutCapturing = [ ];
      recordRegion = [
        "Meta+Shift+R"
        "Meta+R"
      ];
      recordScreen = "Meta+Alt+R";
      recordWindow = "Meta+Ctrl+R";
    };

    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "shutDown";
        powerProfile = "performance";
        turnOffDisplay.idleTimeout = "never";
        whenLaptopLidClosed = "doNothing";
      };
      battery = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "shutDown";
        powerProfile = "performance";
        turnOffDisplay.idleTimeout = "never";
        whenLaptopLidClosed = "doNothing";
      };
      lowBattery = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "shutDown";
        powerProfile = "performance";
        turnOffDisplay.idleTimeout = "never";
        whenLaptopLidClosed = "doNothing";
      };
      batteryLevels = {
        criticalAction = "shutDown";
        criticalLevel = 5;
        lowLevel = 10;
      };
    };

    session.general.askForConfirmationOnLogout = false;
    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

    window-rules = [
      {
        description = "Ulauncher";
        match.window-class = {
          match-whole = false;
          type = "exact";
          value = "ulauncher";
        };
        apply = {
          above = {
            apply = "force";
            value = true;
          };
          fpplevel = {
            apply = "force";
            value = 3;
          };
          noborder = {
            apply = "force";
            value = true;
          };
          position = {
            apply = "initially";
            # FIXME: calculate based on screen size
            value = "550,160";
          };
          skippager = {
            apply = "force";
            value = true;
          };
          skipswitcher = {
            apply = "force";
            value = true;
          };
          skiptaskbar = {
            apply = "force";
            value = true;
          };
        };
      }
      {
        description = "mpv Maximize by default";
        match.window-class = {
          match-whole = false;
          type = "exact";
          value = "mpv";
        };
        apply = {
          maximizehoriz = {
            apply = "initially";
            value = true;
          };
          maximizevert = {
            apply = "initially";
            value = true;
          };
        };
      }
    ];

    workspace = {
      enableMiddleClickPaste = false;
      clickItemTo = "select";
      splashScreen = {
        engine = "none";
        theme = "None";
      };
    };
  };
}
