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
    enable = pkgs.stdenv.hostPlatform.isx86_64 && LT.this.hasTag LT.tags.client;
    scheduler = "scx_bpfland";
    extraArgs = [
      "-m"
      "performance"
      "-w"
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
