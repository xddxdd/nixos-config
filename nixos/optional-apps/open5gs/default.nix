{ pkgs, config, ... }:
{
  imports = [
    ./services.nix
    ./webui.nix
  ];

  environment.etc."freeDiameter".source = ./freeDiameter;
  environment.etc."open5gs".source = ./config;
  environment.etc."open5gs-pkg".source = pkgs.open5gs;

  services.mongodb = {
    enable = true;
    bind_ip = "127.0.0.1";
    package = pkgs.mongodb-ce;
  };
  environment.systemPackages = [ pkgs.mongosh ];
  preservation.preserveAt."/nix/persistent" = {
    directories = [ config.services.mongodb.dbpath ];
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
