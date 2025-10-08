{ tags, geo, ... }:
{
  index = 9;
  tags = with tags; [
    server
    ipv6-only
  ];
  city = geo.cities."CN Hong Kong";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBiZ0rtz7/Ge4NkaVYDCkm7KEjgXOkslc8HmFhOr86dX";
  zerotier = "a863150d72";
  public = {
    IPv6 = "2a14:67c0:306:211::a";
  };
  dn42 = {
    IPv4 = "172.22.76.188";
    region = 52;
  };
}
