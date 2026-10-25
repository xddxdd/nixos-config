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

  # Upstream already confines via RootDirectory; add the harden key set
  systemd.services.tor.serviceConfig = {
    RestartSec = "5s";
  };
  lantian.harden.tor = {
    enable = true;
    enableConfinement = false;
  };
}
