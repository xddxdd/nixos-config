{ tags, geo, ... }:
{
  index = 5;
  tags = with tags; [
    dn42
    public-facing
    server
  ];
  city = geo.cities."JP Tokyo";
  cpuThreads = 2;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErp+D8ITlOFi946F3/GEq+QWsDX9myFeVAwaFBLfqfJ";
  zerotier = "67b3f2d622";
  public = {
    IPv4 = "132.145.123.138";
    IPv6 = "2603:c021:8000:aaaa:2::1";
  };
  dn42 = {
    IPv4 = "172.22.76.123";
    region = 52;
  };
}
