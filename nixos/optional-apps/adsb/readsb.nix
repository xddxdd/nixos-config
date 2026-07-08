{ LT, config, ... }:
{
  imports = [ ./readsb-module.nix ];

  services.readsb = {
    adsb-1090 = {
      enableNetworking = true;
      latitudeFile = config.sops.secrets.adsb-lat.path;
      longitudeFile = config.sops.secrets.adsb-lon.path;

      uuidFile = config.sops.secrets.adsb-uuid.path;

      netBindAddress = LT.this.ltnet.IPv4;
      netHeartbeat = 35;

      netRawInputPort = LT.port.Dump1090.RawInput;
      netRawOutputPort = LT.port.Dump1090.RawOutput;
      netBaseStationOutputPort = LT.port.Dump1090.BaseStation;
      netBeastInputPort = LT.port.Dump1090.BeastInput;
      netBeastOutputPort = LT.port.Dump1090.BeastOutput;

      deviceType = "rtlsdr";
      device = "stx:1090:0";
      gain = "auto";

      netConnector = [
        # 978MHz in
        {
          host = LT.this.ltnet.IPv4;
          port = LT.port.Dump978.Raw;
          protocol = "uat_in";
        }

        # keep-sorted start block=yes
        {
          host = "data.avdelphi.com";
          port = 24999;
          protocol = "beast_reduce_plus_out";
        }
        {
          host = "dati.flyitalyadsb.com";
          port = 4905;
          protocol = "beast_reduce_plus_out";
        }
        {
          host = "feed.adsb.fi";
          port = 30004;
          protocol = "beast_reduce_plus_out";
        }
        {
          host = "feed.airplanes.live";
          port = 30004;
          protocol = "beast_reduce_plus_out";
        }
        {
          host = "feed.planespotters.net";
          port = 30004;
          protocol = "beast_reduce_plus_out";
        }
        {
          host = "feed.theairtraffic.com";
          port = 30004;
          protocol = "beast_reduce_plus_out";
        }
        {
          host = "feed1.adsbexchange.com";
          port = 30004;
          protocol = "beast_reduce_plus_out";
        }
        {
          host = "in.adsb.lol";
          port = 30004;
          protocol = "beast_reduce_plus_out";
        }
        {
          host = "skyfeed.hpradar.com";
          port = 30004;
          protocol = "beast_reduce_plus_out";
        }
        # keep-sorted end
      ];

      extraOptions = [ "--quiet" ];
    };

    mlat = {
      enableNetworking = true;
      latitudeFile = config.sops.secrets.adsb-lat.path;
      longitudeFile = config.sops.secrets.adsb-lon.path;

      uuidFile = config.sops.secrets.adsb-uuid.path;

      netBindAddress = LT.this.ltnet.IPv4;
      netHeartbeat = 35;

      netBeastInputPort = LT.port.UltraFeeder.MlatHubBeastInput;
      netBeastOutputPort = LT.port.UltraFeeder.MlatHubBeastOutput;

      netConnector = [
        # Feed MLAT result back to ADSB 1090MHz instance
        {
          host = LT.this.ltnet.IPv4;
          port = LT.port.Dump1090.BeastInput;
          protocol = "beast_out";
        }
        # PlaneWatch
        {
          host = LT.this.ltnet.IPv4;
          port = LT.port.UltraFeeder.PlaneWatch;
          protocol = "beast_in";
        }
      ];
    };
  };
}
