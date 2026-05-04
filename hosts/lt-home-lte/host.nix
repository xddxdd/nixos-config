{ tags, geo, ... }:
{
  index = 110;
  tags = with tags; [ lan-access ];
  hostname = "192.168.0.9";
  cpuThreads = 4;
  city = geo.cities."US Bellevue";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBxrIX4CD7YIEOBeo02Jcck3BYesAOoCZ8fjCBG6fxk";
  zerotier = "7694587830";
  firewalled = true;
  interconnect = {
    name = "home-lan";
    IPv4 = "192.168.0.9";
    IPv6 = "2001:470:e997::9";
  };
}
