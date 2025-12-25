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
    };
  };
}
