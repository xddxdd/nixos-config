{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 1;
  x86ArchLevel = 3;
  tags = with tags; [
    dn42
    public-facing
    server
  ];
  city = geo.cities."CN Hong Kong";
  zerotier = null;
  public = {
    IPv4 = "2.26.205.141";
    IPv6 = "2a14:67c4:12::c3";
  };
  dn42 = {
    IPv4 = "172.22.76.186";
    region = constants.dn42.region.Asia-E;
  };
}
