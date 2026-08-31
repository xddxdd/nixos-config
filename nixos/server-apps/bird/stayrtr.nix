{
  LT,
  lib,
  ...
}:
lib.mkIf (LT.this.hasTag LT.tags.dn42) {
  services.stayrtr = {
    rpki = {
      port = LT.port.StayRTR.RPKI;
      metricsPort = LT.port.StayRTR.Metrics.RPKI;
      cache = "/nix/sync-servers/ltnet-scripts/bird/dn42/dn42_stayrtr.conf";
      expire = 86400;
      refresh = 60;
      retry = 60;
    };

    flapalerted = {
      port = LT.port.StayRTR.FlapAlerted;
      metricsPort = LT.port.StayRTR.Metrics.FlapAlerted;
      cache = "https://flapalerted.lantian.pub/flaps/active/roa";
      expire = 3600;
      refresh = 60;
      retry = 60;
    };

    "flap42-strexp" = {
      port = LT.port.StayRTR.Flap42;
      metricsPort = LT.port.StayRTR.Metrics.Flap42;
      cache = "https://flap42-data.strexp.net/min_3.json";
      expire = 3600;
      refresh = 300;
      retry = 300;
    };
  };
}
