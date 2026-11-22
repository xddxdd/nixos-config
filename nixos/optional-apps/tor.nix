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
  # Confinement stays off: tor.service sets its own RootDirectory (runDir/root)
  # with RootDirectoryStartOnly=true. Confinement assigns RootDirectory too, and
  # two plain definitions of different values fail to merge at eval time;
  # RootDirectoryStartOnly additionally trips the module's confinement assert.
  # Upstream already chroots the daemon with the full ProtectSystem=strict set.
  lantian.harden.tor = {
    enable = true;
    enableConfinement = false;
  };
}
