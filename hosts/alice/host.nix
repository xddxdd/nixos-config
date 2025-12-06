{ tags, geo, ... }:
{
  index = 1;
  tags = with tags; [
    dn42
    public-facing
    server
  ];
  city = geo.cities."CN Hong Kong";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBiZ0rtz7/Ge4NkaVYDCkm7KEjgXOkslc8HmFhOr86dX";
  zerotier = "a863150d72";
  public = {
    IPv4 = "5.102.125.26";
    IPv6 = "2a14:67c0:306:211::a";
  };
  dn42 = {
    IPv4 = "172.22.76.186";
    region = 52;
  };
}
