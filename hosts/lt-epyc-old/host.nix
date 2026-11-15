{
  tags,
  geo,
  ...
}:
{
  index = 111;
  x86ArchLevel = 3;
  tags = [ tags."cuda-pascal" ];
  cpuThreads = 64;
  vramGB = 48;
  city = geo.cities."US Bellevue";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTU3jpokfmFwY1u5JfWvu/sSz0s0Cvut36iwxbsNojS root@bootstrap";
  zerotier = "b207a3e590";
  firewalled = true;
  hostname = "192.168.0.7";
  interconnect = {
    name = "home-lan";
    IPv4 = "192.168.0.7";
    IPv6 = "2001:470:e997::7";
    internalIPv6Ranges = [ "2001:470:e997::/48" ];
  };
}
