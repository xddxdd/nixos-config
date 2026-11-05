{
  LT,
  ...
}:
{
  services.i2pd = {
    enable = true;
    settings = {
      # Pin the P2P transport port (NTCP2 TCP + SSU2 UDP) inside the
      # per-host WG-lantian forward range; i2pd otherwise picks a random
      # port at every start, which the firewall allowlist cannot track.
      port = LT.this.wg-lantian.forwardStart + LT.portForwardOffset.I2P;
      httpproxy = {
        address = LT.constants.localHost.IPv4;
        port = LT.port.I2P.HTTPProxy;
      };
      sam = {
        enabled = true;
        address = LT.constants.localHost.IPv4;
        port = LT.port.I2P.SAM;
      };
      socksproxy = {
        address = LT.constants.localHost.IPv4;
        port = LT.port.I2P.SocksProxy;
      };
    };
  };

  # I2P peers must reach the router from WAN
  lantian.firewall.presets.public-firewall.allowedPorts = [
    (LT.this.wg-lantian.forwardStart + LT.portForwardOffset.I2P)
  ];

  systemd.services.i2pd.serviceConfig = {
    RestartSec = "5s";
  };
  lantian.harden.i2pd.enable = true;
}
