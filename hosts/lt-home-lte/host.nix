{ tags, geo, ... }:
{
  index = 110;
  x86ArchLevel = 2;
  tags = with tags; [ lan-access ];
  hostname = "192.168.0.9";
  cpuThreads = 4;
  city = geo.cities."US Bellevue";
  zerotier = null;
  firewalled = true;
  interconnect = {
    name = "home-lan";
    IPv4 = "192.168.0.9";
    IPv6 = "2001:470:e997::9";
  };
}
