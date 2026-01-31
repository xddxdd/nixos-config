{ tags, geo, ... }:
{
  index = 14;
  tags = with tags; [
    ipv4-only
    server
  ];
  hostname = "35.208.217.101";
  city = geo.cities."US Council Bluffs";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKKYEnwpn0o1WRxuZNNreQQ+eJDsC8A3TkMOkEmPJ7f";
  zerotier = "ce55407f93";
  public = {
    IPv4 = "35.208.217.101";
  };
  dn42 = {
    IPv4 = "172.22.76.115";
    region = 43;
  };
}
