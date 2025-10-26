{ tags, geo, ... }:
{
  index = 100;
  tags = with tags; [
    client
    nix-builder
  ];
  cpuThreads = 16;
  city = geo.cities."US Seattle";
  hostname = "127.0.0.1";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZp2mN9BALoEjCyvAK27k5AZwOmQqU6ZWi+SXvYezBe";
  zerotier = "9dfea6fa27";
  firewalled = true;
  dn42 = {
    IPv4 = "172.22.76.114";
    region = 42;
  };
}
