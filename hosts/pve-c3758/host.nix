{ tags, geo, ... }:
{
  index = 107;
  x86ArchLevel = 2;
  tags = with tags; [ ];
  city = geo.cities."US Bellevue";
  cpuThreads = 8;
  hostname = "192.168.0.5";
  manualDeploy = true;
  zerotier = null;
}
