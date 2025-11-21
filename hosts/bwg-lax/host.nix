{ tags, geo, ... }:
{
  index = 3;
  tags = with tags; [
    dn42
    public-facing
    server
  ];
  city = geo.cities."US Los Angeles";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7jqK5IsCqMJqJUhAk2oQBQHhvxEb2q39BKNi1VsyOg";
  zerotier = "e6c4934cd7";
  public = {
    IPv4 = "64.64.231.82";
    IPv6 = "2001:470:1f05:159::1";
    IPv6Alt = "2001:470:805e::1";
    IPv6Subnet = "2001:470:805e:ffff::";
  };
  dn42 = {
    IPv4 = "172.22.76.185";
    region = 44;
  };
}
