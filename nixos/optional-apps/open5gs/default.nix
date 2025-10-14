{ pkgs, ... }:
{
  imports = [
    ./kamailio.nix
    ./open5gs-certs.nix
    ./pyhss.nix
    ./rtpengine.nix
    ./services.nix
  ];

  # environment.etc."freeDiameter/hss.conf".source = ./freeDiameter/hss.conf;
  environment.etc."freeDiameter/mme.conf".source = ./freeDiameter/mme.conf;
  environment.etc."freeDiameter/pcrf.conf".source = ./freeDiameter/pcrf.conf;
  environment.etc."freeDiameter/smf.conf".source = ./freeDiameter/smf.conf;
  environment.etc."freeDiameter/lib".source = "${pkgs.open5gs}/lib/freeDiameter";

  networking.hosts = {
    "127.0.0.2" = [ "mme.epc.mnc010.mcc315.3gppnetwork.org" ];
    "127.0.0.4" = [ "smf.epc.mnc010.mcc315.3gppnetwork.org" ];
    "127.0.0.8" = [ "hss.epc.mnc010.mcc315.3gppnetwork.org" ];
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
      "192.168.4.1/24"
      "2001:470:e997:4000::1/52"
    ];
    linkConfig = {
      MTUBytes = 1400;
      RequiredForOnline = false;
    };
    matchConfig.Name = "ogstun";
  };
}
