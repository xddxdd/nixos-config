{ pkgs, lib, ... }:
{
  services.scx = {
    # Broken on aarch64
    enable = pkgs.stdenv.isx86_64;
    scheduler = "scx_pandemonium";
  };

  lantian.preservation.directories = [ "/root/.cache/pandemonium" ];

  systemd.services.scx.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = "3";
  };
}
