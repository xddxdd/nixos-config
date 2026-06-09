{ inputs, ... }:
{
  imports = [
    ./adsb-ultrafeeder.nix
    ./dump978.nix
    # ./dump1090.nix
    ./flightradar24.nix
    ./flightaware.nix
    ./plane-watch.nix
  ];

  sops.secrets.adsb-lat.sopsFile = inputs.secrets + "/adsb.yaml";
  sops.secrets.adsb-lon.sopsFile = inputs.secrets + "/adsb.yaml";
  sops.secrets.adsb-alt.sopsFile = inputs.secrets + "/adsb.yaml";
  sops.secrets.adsb-uuid.sopsFile = inputs.secrets + "/adsb.yaml";
}
