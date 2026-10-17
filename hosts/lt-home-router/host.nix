{ tags, geo, ... }:
{
  index = 112;
  x86ArchLevel = 2;
  tags = with tags; [ ];
  hostname = "192.168.0.1";
  cpuThreads = 4;
  manualDeploy = true;
  city = geo.cities."US Bellevue";
  zerotier = null;
  interconnect = {
    name = "home-lan";
    IPv4 = "192.168.0.1";
    IPv6 = "2001:470:e997::1";
  };
}
