{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  imports = [
    ../../nixos/none.nix
  ];

  boot.loader.grub.enable = lib.mkForce false;

  systemd.network.networks.venet0 = {
    name = "venet0";
    address = [
      "74.201.26.46/24"
      "74.201.26.50/24"
      "2602:fe90:101:127::dc93/64"
    ];
    gateway = [ "2602:fe90:101:127::1" ];
    networkConfig = {
      DHCP = "no";
      DefaultRouteOnDevice = "yes";
      ConfigureWithoutCarrier = "yes";
    };
  };

  services.yggdrasil.regions = [ "united-states" "canada" ];
}
