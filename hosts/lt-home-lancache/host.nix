{ tags, geo, ... }:
{
  index = 110;
  tags = with tags; [ ];
  hostname = "192.168.0.4";
  cpuThreads = 4;
  city = geo.cities."US Seattle";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSEcy/2R5ApnR6nITL9HKfgYPd3zo0G4C3xrTMs5ldz";
  zerotier = "25fded4d0d";
  firewalled = true;
}
