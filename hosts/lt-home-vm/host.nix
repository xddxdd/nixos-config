{ tags, geo, ... }:
{
  index = 101;
  tags = with tags; [
    cuda
    lan-access
    server
  ];
  cpuThreads = 64;
  city = geo.cities."US Seattle";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2yEmewk6E2jKDjJOdrC4k4It2SN+/ihSOwsVmd9fnW";
  zerotier = "606bdb9703";
  firewalled = true;
  public = {
    IPv6 = "2001:470:e997:1::10";
  };
  dn42 = {
    IPv4 = "172.22.76.113";
    region = 42;
  };
  additionalRoutes = [ "10.20.20.77/32" ];
}
