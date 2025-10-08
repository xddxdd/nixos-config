_: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    installBatSyntax = true;
    settings = {
      auto-update = "off";
      keybind = [
        "ctrl+shift+minus=new_split:down"
        "ctrl+shift+plus=new_split:right"
      ];
      mouse-scroll-multiplier = 10;
      unfocused-split-opacity = 1;
      window-height = 25;
      window-inherit-working-directory = true;
      window-step-resize = true;
      window-width = 80;
      shell-integration-features = "ssh-env";
    };
  };
}
