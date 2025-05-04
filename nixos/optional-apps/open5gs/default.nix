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
      "192.168.4.1/24"
      "2001:470:e997:4::1/64"
    ];
    linkConfig = {
      MTUBytes = 1400;
      RequiredForOnline = false;
    };
    matchConfig.Name = "ogstun";
  };
}
