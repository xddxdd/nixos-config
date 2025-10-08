{ tags, geo, ... }:
{
  index = 105;
  tags = with tags; [ ];
  cpuThreads = 4;
  city = geo.cities."US Seattle";
  manualDeploy = true;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLKJi1a8Nd0Ay4VgIstCJn6CdLiMvQygL6KriSZ0Aii";
  zerotier = "0f03503811";
  firewalled = true;
  dn42 = {
    IPv4 = "172.22.76.121";
    region = 42;
  };
}
