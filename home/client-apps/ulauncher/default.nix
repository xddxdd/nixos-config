{ lib, pkgs, ... }:
{
  imports = [
    ./extensions.nix
    ./themes.nix
  ];

  programs.plasma.hotkeys.commands.ulauncher-toggle.command = lib.mkForce (
    toString (
      pkgs.writeShellScript "ulauncher-toggle-session" ''
        if [ "$XDG_SESSION_TYPE" = wayland ]; then
          # The upstream helper ends with X11-only wmctrl; D-Bus already presents the window.
          exec ${pkgs.dbus}/bin/dbus-send --session --print-reply \
            --dest=net.launchpad.ulauncher /net/launchpad/ulauncher \
            net.launchpad.ulauncher.toggle_window
        fi
        exec ${pkgs.ulauncher}/bin/ulauncher-toggle
      ''
    )
  );
}
