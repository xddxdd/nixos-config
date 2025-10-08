{ tags, geo, ... }:
{
  index = 16;
  tags = with tags; [
    low-disk
    server
    ipv6-only
  ];
  city = geo.cities."PL Warsaw";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCz8ucv4kJLTAK9eu+hoXyMINo1Lfm263wske36psS4";
  zerotier = "7c53e2bfd6";
  public = {
    IPv6 = "2001:bc8:1d90:18d1::1";
  };
  dn42 = {
    region = 41;
  };
}
