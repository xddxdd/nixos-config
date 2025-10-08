{ tags, geo, ... }:
{
  index = 109;
  tags = with tags; [ ];
  city = geo.cities."US Seattle";
  cpuThreads = 4;
  hostname = "192.168.0.3";
  manualDeploy = true;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHi4LaLvMfTamfV6iILdPgs3i8q5BhgyaigkPo3V/DZ";
}
