{ tags, geo, ... }:
{
  index = 111;
  tags = with tags; [ lan-access ];
  hostname = "192.168.0.4";
  cpuThreads = 4;
  manualDeploy = true;
  city = geo.cities."US Bellevue";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSEcy/2R5ApnR6nITL9HKfgYPd3zo0G4C3xrTMs5ldz";
  zerotier = "25fded4d0d";
  firewalled = true;
  interconnect = {
    name = "home-lan";
    IPv4 = "192.168.0.4";
    IPv6 = "2001:470:e997::4";
  };
}
