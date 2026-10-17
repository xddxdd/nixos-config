{
  tags,
  geo,
  constants,
  ...
}:
{
  index = 100;
  x86ArchLevel = 4;
  tags = with tags; [
    client
    # cuda
    nix-builder
  ];
  cpuThreads = 16;
  vramGB = 8;
  city = geo.cities."US Bellevue";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPUYgrPlfni2JuLFq4b9HBqjfgCnH5fzJpaWXBK8SGRm root@lt-hp-omen";
  hostname = "127.0.0.1";
  zerotier = "d72228138b";
  firewalled = true;
  dn42 = {
    IPv4 = "172.22.76.114";
    region = constants.dn42.region.North-America-E;
  };
}
