{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 3;
  x86ArchLevel = 2;
  tags = with tags; [
    cn-accel
    dn42
    public-facing
    server
  ];
  city = geo.cities."US Los Angeles";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfV+vW0y8805c8MuGKwM+1lHWrGlEc+wLz66SzorqYw root@bwg-lax";
  zerotier = "a5bfc7d835";
  public = {
    IPv4 = "64.64.231.82";
    IPv6 = "2607:8700:5501:574f::2";
  };
  dn42 = {
    IPv4 = "172.22.76.185";
    region = constants.dn42.region.North-America-W;
  };
}
