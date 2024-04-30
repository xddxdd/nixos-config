{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCodeNF-Reg";
      size = 10;
    };
    theme = "VSCode_Dark";

    keybindings = {
      "ctrl+shift+n" = "new_os_window_with_cwd";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+]" = "next_window";
      "ctrl+shift+[" = "previous_window";
      "ctrl+shift+equal" = "launch --location=vsplit";
      "ctrl+shift+minus" = "launch --location=hsplit";
    };

    settings = {
      remember_window_size = false;
      initial_window_width = "80c";
      initial_window_height = "25c";
      resize_in_steps = true;
      enabled_layouts = "splits";
      confirm_os_window_close = 0;

      wheel_scroll_multiplier = 10;
      wheel_scroll_min_lines = 1;
      touch_scroll_multiplier = 10;

      repaint_delay = 6; # Handle 165 Hz display
      input_delay = 0;
      sync_to_monitor = true;
    };
  };
}
