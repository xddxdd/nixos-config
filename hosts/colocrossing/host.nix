{ tags, geo, ... }:
{
  index = 18;
  tags = with tags; [ ];
  cpuThreads = 8;
  hostname = "23.94.65.218";
  city = geo.cities."US New York City";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUqVaG6JyolBSe1aEQpF2YUnBqr6r+wJy9ZvuB+NZ7u";
  zerotier = "18dd22d2cb";
  public = {
    IPv4 = "23.94.65.218";
  };
  dn42 = {
    IPv4 = "172.22.76.117";
    region = 42;
  };
}
