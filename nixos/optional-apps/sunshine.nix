{
  pkgs,
  config,
  LT,
  ...
}:
{
  services.sunshine = {
    enable = true;
    package = pkgs.sunshine.override {
      cudaSupport = true;
    };
    autoStart = true;
    capSysAdmin = true;

    settings = {
      locale = "zh";
      sunshine_name = config.networking.hostName;
      system_tray = false;
      upnp = LT.this.hasTag LT.tags.client;
      address_family = "both";
      origin_web_ui_allowed = "wan"; # LTNET is considered as WAN
      lan_encryption_mode = 2;
      wan_encryption_mode = 2;

      # Auto adjust screen resolution to client
      global_prep_cmd = builtins.toJSON [
        {
          do = "sh -c \"kscreen-doctor output.HDMI-A-1.mode.\${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@\${SUNSHINE_CLIENT_FPS} || true\"";
          undo = "sh -c \"true\"";
        }
      ];
    };
  };
}
