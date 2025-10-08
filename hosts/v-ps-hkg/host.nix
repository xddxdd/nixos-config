{ tags, geo, ... }:
{
  index = 1;
  tags = with tags; [
    dn42
    public-facing
    server
  ];
  city = geo.cities."CN Hong Kong";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOr1Sq4OSSjirG3kVybjypj0s7nEtx4F23ISgxSRQvV";
  zerotier = "c61df0c319";
  public = {
    IPv4 = "95.214.164.82";
    IPv6 = "2403:2c80:b::12cc";
  };
  dn42 = {
    IPv4 = "172.22.76.186";
    region = 52;
  };
}
