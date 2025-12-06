{ tags, geo, ... }:
{
  index = 9;
  tags = with tags; [
    server
  ];
  hostname = "38.175.199.35";
  city = geo.cities."CN Hong Kong";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOr1Sq4OSSjirG3kVybjypj0s7nEtx4F23ISgxSRQvV";
  zerotier = "c61df0c319";
  public = {
    IPv4 = "38.175.199.35";
    IPv6 = "2001:470:19:c66::1";
  };
  dn42 = {
    IPv4 = "172.22.76.188";
    region = 52;
  };
}
