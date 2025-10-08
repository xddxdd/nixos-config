{
  tags,
  geo,
  ...
}:
{
  index = 14;
  tags = with tags; [
    public-facing
    server
  ];
  system = "aarch64-linux";
  cpuThreads = 8;
  city = geo.cities."DE Nurnberg";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII0/Xn93xTjMcdYHlmQ7MBgN2bx3o5bLdcEauWyfNoX9";
  zerotier = "6ae099ae13";
  public = {
    IPv4 = "159.69.30.238";
    IPv6 = "2a01:4f8:c2c:8bbf::1";
  };
  dn42 = {
    IPv4 = "172.22.76.115";
    region = 41;
  };
}
