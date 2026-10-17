{ tags, geo, ... }:
{
  index = 109;
  tags = with tags; [ ];
  city = geo.cities."US Bellevue";
  cpuThreads = 4;
  hostname = "192.168.0.3";
  manualDeploy = true;
}
