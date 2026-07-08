{
  LT,
  config,
  lib,
  ...
}:
{
  services.mlat-client =
    lib.mapAttrs
      (_: v: {
        inherit (v) server;
        results = [
          {
            protocol = "beast";
            mode = "connect";
            host = LT.this.ltnet.IPv4;
            port = LT.port.UltraFeeder.MlatHubBeastInput;
          }
        ];

        latitudeFile = config.sops.secrets.adsb-lat.path;
        longitudeFile = config.sops.secrets.adsb-lon.path;
        altitudeFile = config.sops.secrets.adsb-alt.path;

        inputConnect = "${LT.this.ltnet.IPv4}:${LT.portStr.Dump1090.BeastOutput}";
        mlatUser = "lantian";
        uuidFile = config.sops.secrets.adsb-uuid.path;
      })
      {
        # keep-sorted start block=yes
        adsbexchange.server = "feed.adsbexchange.com:31090";
        adsbfi.server = "feed.adsb.fi:31090";
        adsblol.server = "in.adsb.lol:31090";
        airplaneslive.server = "feed.airplanes.live:31090";
        flyitalyadsb.server = "dati.flyitalyadsb.com:30100";
        hpradar.server = "skyfeed.hpradar.com:31090";
        planespotters.server = "mlat.planespotters.net:31090";
        theairtraffic.server = "feed.theairtraffic.com:31090";
        # keep-sorted end
      };
}
