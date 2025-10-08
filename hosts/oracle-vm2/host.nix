{ tags, geo, ... }:
{
  index = 7;
  tags = with tags; [
    public-facing
    server
  ];
  city = geo.cities."JP Tokyo";
  cpuThreads = 2;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzrBeumtGvE+EZ0qlHMs43DMQ+jBXawKa4ztYFS2cTb";
  zerotier = "7f008355de";
  public = {
    IPv4 = "140.238.54.105";
    IPv6 = "2603:c021:8000:aaaa:3::1";
  };
  dn42 = {
    IPv4 = "172.22.76.124";
    region = 52;
  };
}
