{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  services.scx = {
    # Broken on aarch64
    # Only enable on client, uncertain improvements on server
    enable = pkgs.stdenv.isx86_64 && LT.this.hasTag LT.tags.client;
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
        ];
  };

  lantian.preservation.directories = [ "/root/.cache/pandemonium" ];

  systemd.services.scx = {
    inherit (config.services.scx) enable;
    serviceConfig = lib.mkIf config.services.scx.enable {
      Restart = lib.mkForce "always";
      RestartSec = "3";
    };
  };
}
