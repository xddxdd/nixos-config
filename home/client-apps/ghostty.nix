{
  lib,
  pkgs,
  config,
  ...
}:
let
  ghostty-service-wrapper = lib.hiPrio (
    pkgs.runCommand "ghostty-service-wrapper" { } ''
      install -Dm644 \
        ${config.programs.ghostty.package}/share/applications/com.mitchellh.ghostty.desktop \
        $out/share/applications/com.mitchellh.ghostty.desktop
      substituteInPlace $out/share/applications/com.mitchellh.ghostty.desktop \
        --replace-fail "DBusActivatable=true" "DBusActivatable=false"

      mkdir -p $out/share/systemd/user
      ln -sf /dev/null $out/share/systemd/user/app-com.mitchellh.ghostty.service
    ''
  );
in
{
  home.packages = [ ghostty-service-wrapper ];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    installBatSyntax = true;
    systemd.enable = false;
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

      font-family = lib.mkForce [
        "FiraCode Nerd Font"
        "Blobmoji"
      ];
      font-family-bold = lib.mkForce [
        "FiraCode Nerd Font"
        "Blobmoji"
      ];
      font-family-italic = lib.mkForce [
        "FiraCode Nerd Font"
        "Blobmoji"
      ];
      font-family-bold-italic = lib.mkForce [
        "FiraCode Nerd Font"
        "Blobmoji"
      ];
      font-size = 10;

      background-opacity = 0;
    };
  };
}
