{ tags, geo, ... }:
{
  index = 11;
  tags = with tags; [
    public-facing
    server
  ];
  city = geo.cities."NO Sandefjord";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3gI3Xp4vuhLA7syB110Dt46tAZQvBm+TEQ7Pg25HY7";
  zerotier = "1c6f6dc3de";
  public = {
    IPv4 = "194.32.107.228";
    IPv6 = "2a03:94e0:ffff:194:32:107::228";
    IPv6Alt = "2a03:94e0:27ca::1";
  };
  dn42 = {
    IPv4 = "172.22.76.122";
    region = 41;
  };
}
