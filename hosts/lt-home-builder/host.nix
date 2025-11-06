{ tags, geo, ... }:
{
  index = 103;
  tags = with tags; [
    lan-access
    nix-builder
  ];
  cpuThreads = 64;
  city = geo.cities."US Seattle";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMi22OSbQGOsXgYWtfMTkHB9IS1y0EKDfrQRqvafAeKN";
  zerotier = "3030836111";
  firewalled = true;
  public = {
    IPv6 = "2001:470:e997:1::12";
  };
}
