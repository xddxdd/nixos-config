{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./dump978.nix
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

  services.udev.packages = [ pkgs.rtl-sdr ];
  users.groups.plugdev = { };

  users.users.adsb = {
    group = "adsb";
    isSystemUser = true;
    extraGroups = [ "plugdev" ];
  };
  users.groups.adsb = { };

  users.users.readsb.extraGroups = [ "adsb" ];
  users.users.mlat-client.extraGroups = [ "adsb" ];
}
