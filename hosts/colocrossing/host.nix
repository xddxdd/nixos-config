{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 8;
  x86ArchLevel = 2;
  tags = with tags; [
    dn42
    public-facing
    server
  ];
  cpuThreads = 8;
  hostname = "23.94.65.218";
  city = geo.cities."US New York City";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1UoThuUBGlXtwI8shM2+ge/9VWBzwUE7kDvW2BvHgK root@colocrossing";
  zerotier = "956b40425d";
  public = {
    IPv4 = "23.94.65.218";
    IPv6 = "2001:470:1f07:6fe::1";
    IPv6Alt = "2001:470:8c19::1";
    IPv6Subnet = "2001:470:8c19:ffff::";
  };
  dn42 = {
    IPv4 = "172.22.76.190";
    region = constants.dn42.region.North-America-E;
  };
}
