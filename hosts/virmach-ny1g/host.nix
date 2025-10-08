{ tags, geo, ... }:
{
  index = 8;
  tags = with tags; [
    dn42
    server
  ];
  city = geo.cities."US New York City";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Oz+8RCV4amTUqd5BwLJ1gqkhyVhDItoevMwczN3Ry";
  zerotier = "9e0a041298";
  public = {
    IPv4 = "45.42.214.121";
    IPv6 = "2001:470:1f07:54d::1";
    IPv6Alt = "2001:470:8a6d::1";
    IPv6Subnet = "2001:470:8a6d:ffff::";
  };
  dn42 = {
    IPv4 = "172.22.76.190";
    region = 42;
  };
}
