{
  LT,
  pkgs,
  config,
  ...
}:
{
  services.flaresolverr = {
    enable = true;
    package = pkgs.flaresolverr;
    port = LT.port.FlareSolverr;
  };

  systemd.services.flaresolverr.environment = {
    HOST = "127.0.0.1";
    LOG_LEVEL = "warn";
    TZ = config.time.timeZone;
    LANG = config.i18n.defaultLocale;
    TEST_URL = "https://www.example.com";
  };
}
