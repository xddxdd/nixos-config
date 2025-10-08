{ tags, geo, ... }:
{
  index = 17;
  tags = with tags; [
    server
    ipv6-only
    low-disk
    low-ram
  ];
  hostname = "2a14:67c0:105:10a::a";
  city = geo.cities."CN Hong Kong";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiCk13WHo2VksK6U083dWrSysE8IS47Z4RESE50W4vS";
  zerotier = "81d0263128";
  public = {
    IPv6 = "2a14:67c0:105:10a::a";
  };
  dn42 = {
    IPv4 = "172.22.76.189";
    region = 52;
  };
}
