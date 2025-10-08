{ tags, geo, ... }:
{
  index = 15;
  tags = with tags; [
    low-disk
    server
    ipv6-only
  ];
  city = geo.cities."NL Amsterdam";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWSI6klO/G6LkGeZqAd8iR7f43S5bTo4RrwTnP8RRyY";
  zerotier = "6dc4324888";
  public = {
    IPv6 = "2001:bc8:1640:4f1f::1";
  };
  dn42 = {
    region = 41;
  };
}
