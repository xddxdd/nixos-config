{ inputs, lib, ... }:
{
  imports = [
    ./dump978.nix
    # ./dump1090.nix
    ./flightradar24.nix
    ./flightaware.nix
    ./mlat.nix
    ./readsb.nix
    ./plane-watch.nix
  ];

  sops.secrets =
    lib.genAttrs
      [
        "adsb-lat"
        "adsb-lon"
        "adsb-alt"
        "adsb-uuid"
      ]
      (_: {
        sopsFile = inputs.secrets + "/adsb.yaml";
        owner = "adsb";
        group = "adsb";
        mode = "0440";
      });

  users.users.adsb = {
    group = "adsb";
    isSystemUser = true;
  };
  users.groups.adsb = { };

  users.users.readsb.extraGroups = [ "adsb" ];
  users.users.mlat-client.extraGroups = [ "adsb" ];
}
