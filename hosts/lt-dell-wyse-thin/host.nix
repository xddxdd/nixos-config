{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 105;
  tags = with tags; [ ];
  cpuThreads = 4;
  city = geo.cities."US Bellevue";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEKcw0Vv7AmQRcsZgcOBgTCXRlCMnrn3lRS6+XtvgOOv root@lt-dell-wyse-thin";
  zerotier = "cafbf30f5b";
  firewalled = true;
  hostname = "192.168.0.208";
  dn42 = {
    IPv4 = "172.22.76.121";
    region = constants.dn42.region.North-America-E;
  };
}
