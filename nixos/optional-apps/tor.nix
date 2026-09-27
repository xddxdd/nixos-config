{ LT, ... }:
{
  services.tor = {
    enable = true;
    client = {
      enable = true;
      socksListenAddress = {
        addr = LT.constants.localHost.IPv4;
        port = LT.port.Tor.Socks;
      };
    };
  };
}
