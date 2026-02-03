{ tags, geo, ... }:
{
  index = 112;
  tags = with tags; [ ];
  hostname = "192.168.0.1";
  cpuThreads = 4;
  city = geo.cities."US Seattle";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLpHoRAgRF8ub5vIm0Ah0ZF+0PgEJXP/2o2R9yAywqo";
  zerotier = "e8b266c1c1";
}
