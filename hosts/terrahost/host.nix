{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 11;
  x86ArchLevel = 3;
  tags = with tags; [
    public-facing
    server
  ];
  city = geo.cities."NO Sandefjord";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/cnITTzfVRdAbforhVZUXemDZ4DCLNOVVOdP6tCECn root@terrahost";
  zerotier = "1b0c824916";
  public = {
    IPv4 = "194.32.107.228";
    IPv6 = "2a03:94e0:ffff:194:32:107::228";
    IPv6Alt = "2a03:94e0:27ca::1";
  };
  dn42 = {
    IPv4 = "172.22.76.122";
    region = constants.dn42.region.Europe;
  };
}
