{ tags, geo, ... }:
{
  index = 10;
  tags = with tags; [
    public-facing
    server
  ];
  city = geo.cities."US Seattle";
  cpuThreads = 2;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKXYFTOUNHp3n1M/oPBhqrgAWCTJm7wys098P4NPzou";
  zerotier = "4b1e8d0849";
  public = {
    IPv4 = "23.145.48.11";
    IPv6 = "2605:3a40:4::142";
  };
  dn42 = {
    IPv4 = "172.22.76.120";
    region = 44;
  };
}
