{ tags, geo, ... }:
{
  index = 2;
  tags = with tags; [
    dn42
    low-disk
    low-ram
    server
  ];
  hostname = "107.189.12.254";
  city = geo.cities."CH Bern";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKncnTrQSX37j2kODCMb/d6+qoDgMg5zJIVgPCOYolNK";
  zerotier = "f01c76d61a";
  public = {
    IPv4 = "107.189.12.254";
    IPv6 = "2605:6400:30:f22f::1";
    IPv6Alt = "2605:6400:cac6::1";
    IPv6Subnet = "2605:6400:cac6:ffff::";
  };
  dn42 = {
    IPv4 = "172.22.76.187";
    region = 41;
  };
}
