{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 7;
  x86ArchLevel = 3;
  tags = with tags; [
    public-facing
    server
  ];
  city = geo.cities."JP Tokyo";
  cpuThreads = 2;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP55X/sjMFfiHpXsbqr5J7L/ggm8OqHwsXXvla6o/f/e root@oracle-vm2";
  zerotier = "bfa7ce99d1";
  public = {
    IPv4 = "140.238.54.105";
    IPv6 = "2603:c021:8000:aaaa:3::1";
  };
  interconnect = {
    name = "oci";
    IPv4 = "172.18.126.3";
  };
  dn42 = {
    IPv4 = "172.22.76.124";
    region = constants.dn42.region.Asia-E;
  };
}
