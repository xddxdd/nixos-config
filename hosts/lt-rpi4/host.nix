{ tags, geo, ... }:
{
  index = 106;
  system = "aarch64-linux";
  tags = with tags; [ ];
  city = geo.cities."US Seattle";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ7wA62a0cowKd4FttudzWfs0GL1wLxCfEOG9QM+odgV";
  zerotier = "a53c247aa1";
  firewalled = true;
  dn42 = {
    IPv4 = "172.22.76.125";
    region = 42;
  };
}
