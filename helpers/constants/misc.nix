{ lib, ... }:
{
  forceX11WrapperArgs = builtins.concatStringsSep " " [
    "--set QT_QPA_PLATFORM xcb"
    "--set XDG_SESSION_TYPE x11"
    "--set GTK_IM_MODULE fcitx"
    "--set QT_IM_MODULE fcitx"
    "--unset WAYLAND_DISPLAY"
  ];

  stateVersion = "24.05";

  tags = lib.genAttrs [
    # Usage
    "client"
    "dn42"
    "nix-builder"
    "public-facing"
    "server"
    "ipv4-only"
    "ipv6-only"
    "lan-access"

    # Hardware
    "cuda"
    "low-disk"
    "low-ram"
  ] (v: v);
}
