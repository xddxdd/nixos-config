{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 108;
  x86ArchLevel = 3;
  tags = with tags; [
    lan-access
    nix-builder
    server
  ];
  city = geo.cities."US Bellevue";
  cpuThreads = 128;
  vramGB = 48;
  hostname = "192.168.0.2";
  manualDeploy = true;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE3PpFGm+OTqrJM55qrxKWLnkwrnnzzMAprNfaXWk/gp";
  zerotier = "e6a5b508a4";
  public = {
    IPv6 = "2001:470:e997::2";
  };
  interconnect = {
    name = "home-lan";
    IPv4 = "192.168.0.2";
    IPv6 = "2001:470:e997::2";
  };
  dn42 = {
    IPv4 = "172.22.76.113";
    region = constants.dn42.region.North-America-E;
  };
}
