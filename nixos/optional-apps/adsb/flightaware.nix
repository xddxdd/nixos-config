{
  inputs,
  LT,
  config,
  ...
}:
{
  sops.secrets.adsb-flightaware-uuid.sopsFile = inputs.secrets + "/adsb.yaml";

  sops.templates.adsb-flightaware-env.content = ''
    FEEDER_ID=${config.sops.placeholder.adsb-flightaware-uuid}
  '';

  virtualisation.oci-containers.containers.adsb-flightaware = {
    image = "ghcr.io/sdr-enthusiasts/docker-piaware";
    labels."io.containers.autoupdate" = "registry";
    environmentFiles = [ config.sops.templates.adsb-flightaware-env.path ];
    environment = {
      TZ = config.time.timeZone;
      RECEIVER_TYPE = "relay";
      BEASTHOST = LT.this.ltnet.IPv4;
      BEASTPORT = LT.portStr.Dump1090.BeastOutput;
      MLAT_RESULTS_BEASTHOST = LT.this.ltnet.IPv4;
      MLAT_RESULTS_BEASTPORT = LT.portStr.UltraFeeder.MlatHubBeastInput;
    };
  };
}
