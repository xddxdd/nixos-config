{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 9;
  x86ArchLevel = 3;
  tags = with tags; [
    cn-accel
    ipv4-only
    public-facing
    server
  ];
  hostname = "38.175.199.35";
  city = geo.cities."CN Hong Kong";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBHe0spTTxgOi7RPU5LGybbh7a76vqWTlVnK69LYows root@zgocloud";
  zerotier = "57a134d631";
  public = {
    IPv4 = "38.175.199.35";
  };
  dn42 = {
    IPv4 = "172.22.76.188";
    region = constants.dn42.region.Asia-E;
  };
}
