{ tags, geo, ... }:
{
  index = 1;
  tags = with tags; [
    dn42
    public-facing
    server
  ];
  hostname = "38.175.199.35";
  city = geo.cities."CN Hong Kong";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOr1Sq4OSSjirG3kVybjypj0s7nEtx4F23ISgxSRQvV";
  zerotier = "c61df0c319";
  public = {
    IPv4 = "38.175.199.35";
    IPv6 = "2001:470:19:c66::1";
    IPv6Alt = "2600:70ff:aa36::1";
    IPv6Subnet = "2600:70ff:aa36:ffff::";
  };
  dn42 = {
    IPv4 = "172.22.76.186";
    region = 52;
  };
}
