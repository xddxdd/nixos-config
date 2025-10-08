{ tags, geo, ... }:
{
  index = 107;
  tags = with tags; [ ];
  city = geo.cities."US Seattle";
  cpuThreads = 8;
  hostname = "192.168.0.5";
  manualDeploy = true;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVVZlKt3hgDvEfZOSKIPxbiDis1TArv4jjKSggJYik4";
}
