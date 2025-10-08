{ tags, geo, ... }:
{
  index = 104;
  tags = with tags; [
    client
  ];
  cpuThreads = 4;
  city = geo.cities."US Seattle";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjBBTtlrrqBSfPS+AMrmKIXqJ0Hlf0isl8tQkAqnNg8";
  zerotier = "b82755cf85";
  firewalled = true;
  dn42 = {
    IPv4 = "172.22.76.118";
    region = 42;
  };
}
