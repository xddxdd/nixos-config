{ tags, geo, ... }:
{
  index = 13;
  tags = with tags; [
    low-disk
    server
    ipv6-only
  ];
  city = geo.cities."FR Paris";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBLbqWpSZzdL4omMvwTgXoOsvkzUNgjAJNw5tMMQ0ch";
  zerotier = "8d7a80a781";
  public = {
    IPv6 = "2001:bc8:710:ebe0::1";
  };
  dn42 = {
    region = 41;
  };
}
