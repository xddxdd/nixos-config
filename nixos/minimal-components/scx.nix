{ pkgs, ... }:
{
  services.scx = {
    # Broken on aarch64
    enable = pkgs.stdenv.isx86_64;
    scheduler = "scx_lavd";
  };
}
