{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 6;
  x86ArchLevel = 3;
  tags = with tags; [
    ipv4-only
    server
  ];
  hostname = "52.229.162.161";
  city = geo.cities."CN Hong Kong";
  cpuThreads = 2;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFlxELcQaifrrNXGIoivl9e6Ht+HWz52SnbIDd5n37b";
  zerotier = "f362194ea3";
  public = {
    IPv4 = "52.229.162.161";
  };
  interconnect = {
    name = "azure";
    IPv4 = "10.2.1.5";
  };
  dn42 = {
    IPv4 = "172.22.76.116";
    region = constants.dn42.region.Asia-E;
  };
  additionalRoutes = [
    "168.63.129.16/32" # Azure private DNS server
  ];
}
