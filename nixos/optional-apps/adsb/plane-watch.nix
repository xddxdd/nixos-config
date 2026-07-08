{
  inputs,
  LT,
  config,
  ...
}:
{
  sops.secrets.adsb-plane-watch-uuid.sopsFile = inputs.secrets + "/adsb.yaml";

  sops.templates.adsb-plane-watch-env.content = ''
    LAT=${config.sops.placeholder.adsb-lat}
    LONG=${config.sops.placeholder.adsb-lon}
    ALT=${config.sops.placeholder.adsb-alt}
    API_KEY=${config.sops.placeholder.adsb-plane-watch-uuid}
  '';

  virtualisation.oci-containers.containers.adsb-plane-watch = {
    image = "ghcr.io/plane-watch/docker-plane-watch";
    labels."io.containers.autoupdate" = "registry";
    ports = [
      "${LT.this.ltnet.IPv4}:${LT.portStr.ADSB.PlaneWatch}:30105"
    ];
    environmentFiles = [ config.sops.templates.adsb-plane-watch-env.path ];
    environment = {
      TZ = config.time.timeZone;
      BEASTHOST = LT.this.ltnet.IPv4;
      BEASTPORT = LT.portStr.ADSB.BeastOutput;
    };
  };
}
