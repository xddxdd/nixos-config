{ tags, geo, ... }:
{
  index = 104;
  tags = with tags; [
    client
  ];
  cpuThreads = 4;
  city = geo.cities."US Bellevue";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjBBTtlrrqBSfPS+AMrmKIXqJ0Hlf0isl8tQkAqnNg8";
  zerotier = "b82755cf85";
  firewalled = true;
  interconnect = {
    name = "home-lan";
    IPv4 = "192.168.0.207";
  };
  dn42 = {
    IPv4 = "172.22.76.118";
    region = 42;
  };
}
