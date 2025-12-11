{ tags, geo, ... }:
{
  index = 108;
  tags = with tags; [ ];
  city = geo.cities."US Seattle";
  cpuThreads = 128;
  hostname = "192.168.0.2";
  manualDeploy = true;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE3PpFGm+OTqrJM55qrxKWLnkwrnnzzMAprNfaXWk/gp";
  zerotier = "e6a5b508a4";
}
