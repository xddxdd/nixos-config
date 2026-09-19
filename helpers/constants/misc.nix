{
  lib,
  dn42,
  neonetwork,
  ...
}:
{
  # Target host MUST have DN42 connectivity
  defaultGatewayHostName = "pve-epyc";
  defaultGatewayHostIPv4Routes = dn42.IPv4 ++ neonetwork.IPv4 ++ [ "198.18.0.0/15" ];
  defaultGatewayHostIPv6Routes = dn42.IPv6 ++ neonetwork.IPv6 ++ [ "fdbc:f9dc:67ad::/48" ];

  forceX11WrapperArgs = builtins.concatStringsSep " " [
    "--set QT_QPA_PLATFORM xcb"
    "--set XDG_SESSION_TYPE x11"
    "--set GTK_IM_MODULE fcitx"
    "--set QT_IM_MODULE fcitx"
    "--unset WAYLAND_DISPLAY"
  ];

  stateVersion = "26.05";

  tags = lib.genAttrs [
    # Usage
    "client"
    "cn-accel"
    "dn42"
    "nix-builder"
    "public-facing"
    "server"
    "ipv4-only"
    "ipv6-only"
    "lan-access"

    # Hardware
    "cuda"
    "low-gpu"
    "low-ram"
  ] (v: v);
}
