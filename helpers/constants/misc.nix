{ lib, ... }:
rec {
  stateVersion = "24.05";

  soundfontPath = pkgs: "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";

  tags = lib.genAttrs [
    # Usage
    "client"
    "dn42"
    "nix-builder"
    "public-facing"
    "server"
    "ipv6-only"
    "lan-access"

    # Hardware
    "low-disk"
    "low-ram"
  ] (v: v);
}
