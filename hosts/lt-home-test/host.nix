{ tags, geo, ... }:
{
  index = 102;
  tags = with tags; [ ];
  cpuThreads = 8;
  city = geo.cities."US Seattle";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHq9gnvAZdEt84vZf83s4+T+3AhPVY/xz2o5qbqR8ftx";
  public = {
    IPv6 = "2001:470:e997:1::13";
  };
  zerotier = "fb4c304816";
  firewalled = true;
}
