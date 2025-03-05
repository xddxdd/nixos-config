{
  LT,
  pkgs,
  config,
  ...
}:
{
  services.flaresolverr = {
    enable = true;
    package = pkgs.nur-xddxdd.flaresolverr-alexfozor;
    port = LT.port.FlareSolverr;
  };

  systemd.services.flaresolverr.environment = {
    HOST = "127.0.0.1";
    TZ = config.time.timeZone;
    LANG = config.i18n.defaultLocale;
    TEST_URL = "https://www.example.com";
  };
}
