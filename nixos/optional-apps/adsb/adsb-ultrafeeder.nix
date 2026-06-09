{
  lib,
  LT,
  config,
  ...
}:
{
  sops.templates.adsb-ultrafeeder-env.content = ''
    LAT=${config.sops.placeholder.adsb-lat}
    LONG=${config.sops.placeholder.adsb-lon}
    ALT=${config.sops.placeholder.adsb-alt}
    UUID=${config.sops.placeholder.adsb-uuid}
  '';

  virtualisation.oci-containers.containers.adsb-ultrafeeder = {
    image = "ghcr.io/sdr-enthusiasts/docker-adsb-ultrafeeder";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    extraOptions = [
      "--device=/dev/bus/usb"
      "--device-cgroup-rule=c 189:* rwm"
    ];
    ports = [
      "${LT.this.ltnet.IPv4}:${LT.portStr.Dump1090.RawInput}:30001"
      "${LT.this.ltnet.IPv4}:${LT.portStr.Dump1090.RawOutput}:30002"
      "${LT.this.ltnet.IPv4}:${LT.portStr.Dump1090.BaseStation}:30003"
      "${LT.this.ltnet.IPv4}:${LT.portStr.Dump1090.BeastInput}:30004"
      "${LT.this.ltnet.IPv4}:${LT.portStr.Dump1090.BeastOutput}:30005"
      "${LT.this.ltnet.IPv4}:${LT.portStr.UltraFeeder.MlatHubBeastInput}:31004"
      "${LT.this.ltnet.IPv4}:${LT.portStr.UltraFeeder.MlatHubBeastOutput}:31005"
      "127.0.0.1:${LT.portStr.UltraFeeder.HTTP}:80"
    ];
    environmentFiles = [ config.sops.templates.adsb-ultrafeeder-env.path ];
    environment = {
      TZ = config.time.timeZone;

      READSB_DEVICE_TYPE = "rtlsdr";
      READSB_GAIN = "auto";
      READSB_RTLSDR_DEVICE = "stx:1090:0";
      READSB_STATS_RANGE = "true";
      UPDATE_TAR1090 = "true";
      TAR1090_MESSAGERATEINTITLE = "true";
      TAR1090_PAGETITLE = "${config.networking.hostName} ADS-B";
      TAR1090_PLANECOUNTINTITLE = "true";
      TAR1090_ENABLE_AC_DB = "true";
      GRAPHS1090_DARKMODE = "true";

      ENABLE_978 = "true";
      URL_978 = "https://dump978.${config.networking.hostName}.xuyh0120.win";

      MLAT_USER = "lantian";
      ULTRAFEEDER_CONFIG = lib.join ";" [
        # Dump978 connection
        "adsb,${LT.this.ltnet.IPv4},${LT.portStr.Dump978.Raw},uat_in"

        # External connection
        "mlathub,${LT.this.ltnet.IPv4},${LT.portStr.UltraFeeder.PlaneWatch},beast_in"

        # ADSB/MLAT feeds
        # keep-sorted start
        "adsb,data.avdelphi.com,24999,beast_reduce_plus_out"
        "adsb,dati.flyitalyadsb.com,4905,beast_reduce_plus_out"
        "adsb,feed.adsb.fi,30004,beast_reduce_plus_out"
        "adsb,feed.airplanes.live,30004,beast_reduce_plus_out"
        "adsb,feed.planespotters.net,30004,beast_reduce_plus_out"
        "adsb,feed.theairtraffic.com,30004,beast_reduce_plus_out"
        "adsb,feed1.adsbexchange.com,30004,beast_reduce_plus_out"
        "adsb,in.adsb.lol,30004,beast_reduce_plus_out"
        "adsb,skyfeed.hpradar.com,30004,beast_reduce_plus_out"
        "mlat,dati.flyitalyadsb.com,30100,39007"
        "mlat,feed.adsb.fi,31090,39000"
        "mlat,feed.adsbexchange.com,31090,39008"
        "mlat,feed.airplanes.live,31090,39002"
        "mlat,feed.theairtraffic.com,31090,39004"
        "mlat,in.adsb.lol,31090,39001"
        "mlat,mlat.planespotters.net,31090,39003"
        "mlat,skyfeed.hpradar.com,31090,39005"
        # keep-sorted end
      ];
    };
    volumes = [
      "/var/lib/adsb-ultrafeeder/globe_history:/var/globe_history"
      "/var/lib/adsb-ultrafeeder/graphs1090:/var/lib/collectd"
      "/proc/diskstats:/proc/diskstats:ro"
    ];
  };

  systemd.tmpfiles.settings.adsb-ultrafeeder = {
    "/var/lib/adsb-ultrafeeder/globe_history"."d" = {
      mode = "755";
      user = "root";
      group = "root";
    };
    "/var/lib/adsb-ultrafeeder/graphs1090"."d" = {
      mode = "755";
      user = "root";
      group = "root";
    };
  };

  lantian.nginxVhosts."adsb.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.UltraFeeder.HTTP}";
      };
    };

    accessibleBy = "private";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
