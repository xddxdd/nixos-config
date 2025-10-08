{ tags, geo, ... }:
{
  index = 110;
  tags = with tags; [ ];
  hostname = "192.168.0.9";
  cpuThreads = 4;
  city = geo.cities."US Seattle";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBxrIX4CD7YIEOBeo02Jcck3BYesAOoCZ8fjCBG6fxk";
  zerotier = "7694587830";
  firewalled = true;
}
