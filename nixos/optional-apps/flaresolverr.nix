{
  LT,
  config,
  pkgs,
  ...
}:
{
  services.flaresolverr = {
    enable = true;
    package = pkgs.nur-xddxdd.flaresolverr-21hsmw;
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
