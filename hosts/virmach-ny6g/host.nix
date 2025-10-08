{ tags, geo, ... }:
{
  index = 4;
  tags = with tags; [
    server
  ];
  city = geo.cities."US New York City";
  cpuThreads = 2;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjmwZpgsCSqgs4kTRqLbkS1uRnNTLGweRqK+YrXs7Qf";
  zerotier = "9179b9ee84";
  public = {
    IPv4 = "45.42.214.124";
    IPv6 = "2001:470:1f07:c6f::1";
    IPv6Alt = "2001:470:8d00::1";
    IPv6Subnet = "2001:470:8d00:ffff::";
  };
  dn42 = {
    IPv4 = "172.22.76.126";
    region = 42;
  };
}
