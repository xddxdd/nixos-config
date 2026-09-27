{
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
      "${LT.constants.localHost.IPv4}/32"
      "${LT.constants.localHost.IPv6}/128"
    ]
    ++ LT.this._addresses;
  };
}
