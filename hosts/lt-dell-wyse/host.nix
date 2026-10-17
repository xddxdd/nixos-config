{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 104;
  x86ArchLevel = 2;
  tags = with tags; [
    client
    low-gpu
  ];
  cpuThreads = 4;
  city = geo.cities."US Bellevue";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+nkuHwpntl59FxnDY//bUUjDZgxFiV90TdIa9zcl5M root@lt-dell-wyse";
  zerotier = "91a183015a";
  firewalled = true;
  hostname = "192.168.0.207";
  interconnect = {
    name = "home-lan";
    IPv4 = "192.168.0.207";
  };
  dn42 = {
    IPv4 = "172.22.76.118";
    region = constants.dn42.region.North-America-E;
  };
}
