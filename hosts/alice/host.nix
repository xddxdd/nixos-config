{
  tags,
  geo,
  constants,
  ...
}:
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
    IPv4 = "2.26.205.141";
    IPv6 = "2a14:67c4:12::c3";
  };
  dn42 = {
    IPv4 = "172.22.76.186";
    region = constants.dn42.region.Asia-E;
  };
}
