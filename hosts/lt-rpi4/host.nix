{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 106;
  system = "aarch64-linux";
  tags = with tags; [ lan-access ];
  city = geo.cities."US Bellevue";
  zerotier = null;
  firewalled = true;
  interconnect = {
    name = "home-lan";
    IPv4 = "192.168.0.6";
    IPv6 = "2001:470:e997::6";
  };
  dn42 = {
    IPv4 = "172.22.76.125";
    region = constants.dn42.region.North-America-E;
  };
}
