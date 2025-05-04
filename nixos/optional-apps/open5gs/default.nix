{ pkgs, ... }:
{
  imports = [
    ./kamailio.nix
    ./pyhss.nix
    ./rtpengine.nix
    ./services.nix
    ./webui.nix
    ../mongodb.nix
  ];

  environment.etc."freeDiameter".source = ./freeDiameter;
  environment.etc."open5gs-pkg".source = pkgs.open5gs;

  networking.hosts = {
    "127.0.0.47" = [ "hss.ims.mnc010.mcc315.3gppnetwork.org" ];
    "127.0.0.9" = [ "pcrf.epc.mnc010.mcc315.3gppnetwork.org" ];
  };

  systemd.network.netdevs.open5gs = {
    netdevConfig = {
      Kind = "tun";
      Name = "ogstun";
    };
  };

  systemd.network.networks.open5gs = {
    address = [
      "10.45.0.1/16"
      "2001:db8:cafe::1/48"
    ];
    linkConfig = {
      MTUBytes = 1400;
      RequiredForOnline = false;
    };
    matchConfig.Name = "ogstun";
  };
}
