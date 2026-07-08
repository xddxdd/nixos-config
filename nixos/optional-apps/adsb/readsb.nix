{ LT, config, ... }:
let
  commonArgs = {
    enableNetworking = true;
    latitudeFile = config.sops.secrets.adsb-lat.path;
    longitudeFile = config.sops.secrets.adsb-lon.path;

    uuidFile = config.sops.secrets.adsb-uuid.path;

    netBindAddress = LT.this.ltnet.IPv4;
    netHeartbeat = 35;

    extraOptions = [ "--quiet" ];
  };
in
{
  services.readsb = {
    adsb = commonArgs // {
      netRawInputPort = LT.port.ADSB.RawInput;
      netRawOutputPort = LT.port.ADSB.RawOutput;
      netBaseStationOutputPort = LT.port.ADSB.BaseStationOutput;
      netBeastInputPort = LT.port.ADSB.BeastInput;
      netBeastOutputPort = LT.port.ADSB.BeastOutput;

      deviceType = "rtlsdr";
      device = "stx:1090:0";
      gain = "auto";

      netConnector = [
        # 978MHz in
        {
          host = LT.this.ltnet.IPv4;
          port = LT.port.ADSB.RawOutput978;
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
    };

    mlat = commonArgs // {
      netBeastInputPort = LT.port.ADSB.MlatHubBeastInput;
      netBeastOutputPort = LT.port.ADSB.MlatHubBeastOutput;

      netConnector = [
        # Feed MLAT result back to ADSB 1090MHz instance
        {
          host = LT.this.ltnet.IPv4;
          port = LT.port.ADSB.BeastInput;
          protocol = "beast_out";
        }
        # PlaneWatch
        {
          host = LT.this.ltnet.IPv4;
          port = LT.port.ADSB.PlaneWatch;
          protocol = "beast_in";
        }
      ];
    };
  };
}
