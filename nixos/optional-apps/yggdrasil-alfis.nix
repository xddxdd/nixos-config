{
  pkgs,
  config,
  LT,
  ...
}:

let
  netns = config.lantian.netns.yggdrasil-alfis;

  configFile = pkgs.writeText "alfis.toml" ''
    origin = "0000001D2A77D63477172678502E51DE7F346061FF7EB188A2445ECA3FC0780E"
    key_files = ["key1.toml", "key2.toml", "key3.toml", "key4.toml", "key5.toml"]
    check_blocks = 8

    [net]
    peers = ["peer-v4.alfis.name:4244", "peer-v6.alfis.name:4244", "peer-ygg.alfis.name:4244"]
    listen = "[::]:${LT.portStr.Yggdrasil.Alfis}"
    public = true
    yggdrasil_only = false

    [dns]
    listen = "[fdbc:f9dc:67ad:2547::52]:${LT.portStr.DNS}"
    threads = 50
    forwarders = ["https://dns.adguard.com/dns-query"]
    bootstraps = ["9.9.9.9:53", "94.140.14.14:53"]

    [mining]
    threads = 0
    lower = true
  '';
in
{
  lantian.netns.yggdrasil-alfis = {
    ipSuffix = "52";
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::52"
    ];
    birdBindTo = [ "yggdrasil-alfis.service" ];
  };

  systemd.services.yggdrasil-alfis = netns.bind {
    description = "Alternative Free Identity System";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.alfis-nogui}/bin/alfis -n -c ${configFile}";

      WorkingDirectory = "/var/lib/yggdrasil-alfis";
      StateDirectory = "yggdrasil-alfis";
      User = "yggdrasil-alfis";
      Group = "yggdrasil-alfis";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };

  users.users.yggdrasil-alfis = {
    group = "yggdrasil-alfis";
    isSystemUser = true;
  };
  users.groups.yggdrasil-alfis = { };
}
