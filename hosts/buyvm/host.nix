{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 2;
  x86ArchLevel = 4;
  tags = with tags; [
    dn42
    low-ram
    server
  ];
  hostname = "107.189.12.254";
  city = geo.cities."CH Bern";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQbVssLNg4QyFNxPdho4VJ6eS+VGpbOfLUdf8ZTgYuQ root@buyvm";
  zerotier = "0cb952ba4b";
  public = {
    IPv4 = "107.189.12.254";
    IPv6 = "2605:6400:30:f22f::1";
    IPv6Alt = "2605:6400:cac6::1";
    IPv6Subnet = "2605:6400:cac6:ffff::";
  };
  dn42 = {
    IPv4 = "172.22.76.187";
    region = constants.dn42.region.Europe;
  };
}
