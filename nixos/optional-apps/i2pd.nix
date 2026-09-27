{ LT, ... }:
{
  services.i2pd = {
    enable = true;
    settings = {
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
}
