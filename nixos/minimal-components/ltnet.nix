{
  lib,
  LT,
  ...
}:
{
  systemd.network.netdevs.dummy0 = {
    netdevConfig = {
      Kind = "dummy";
      Name = "dummy0";
    };
  };

  systemd.network.networks.dummy0 = {
    matchConfig = {
      Name = "dummy0";
    };

    networkConfig = {
      IPv6PrivacyExtensions = false;
    };

    address = [
      "198.19.0.1/32"
      "fdbc:f9dc:67ad:2547::1/128"
    ]
    ++ LT.this._addresses;
  };
}
