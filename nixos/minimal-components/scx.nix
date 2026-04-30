{
  pkgs,
  lib,
  LT,
  ...
}:
{
  services.scx = {
    # Broken on aarch64
    enable = pkgs.stdenv.isx86_64;
    scheduler = "scx_flash";
    extraArgs =
      if LT.this.hasTag LT.tags.client then
        [
          "-m"
          "all"
        ]
      else
        [
          "-m"
          "performance"
          "-w"
          "-C"
          "0"
        ];
  };

  lantian.preservation.directories = [ "/root/.cache/pandemonium" ];

  systemd.services.scx.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = "3";
  };
}
