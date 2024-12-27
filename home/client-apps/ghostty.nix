{ pkgs, ... }:
{
  home.packages = [ pkgs.ghostty ];

  xdg.configFile."ghostty/config".text = ''
    auto-update = off
    font-family = FiraCode Nerd Font Reg
    font-family-bold = FiraCode Nerd Font Bold
    font-family-bold-italic = FiraCode Nerd Font Bold
    font-family-italic = FiraCode Nerd Font Reg
    font-size = 12
    keybind = ctrl+shift+minus=new_split:down
    keybind = ctrl+shift+plus=new_split:right
    mouse-scroll-multiplier = 10
    theme = Dark+
    window-height = 25
    window-inherit-working-directory = true
    window-step-resize = true
    window-width = 80
  '';
}
