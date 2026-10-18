{ tags, geo, ... }:
{
  index = 112;
  x86ArchLevel = 2;
  tags = with tags; [ ];
  hostname = "192.168.0.1";
  cpuThreads = 4;
  manualDeploy = true;
  city = geo.cities."US Bellevue";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINl+fW7Bw2TqA484dejYWzP71Jsf5G9IndhbAvA2dtKV";
  zerotier = "2572d756cd";
  interconnect = {
    name = "home-lan";
    IPv4 = "192.168.0.1";
    IPv6 = "2001:470:e997::1";
  };
}
