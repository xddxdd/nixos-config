{ tags, geo, ... }:
{
  index = 4;
  tags = with tags; [
    server
  ];
  city = geo.cities."US New York City";
  cpuThreads = 2;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjmwZpgsCSqgs4kTRqLbkS1uRnNTLGweRqK+YrXs7Qf";
  zerotier = "9179b9ee84";
  public = {
    IPv4 = "45.42.214.124";
  };
  dn42 = {
    IPv4 = "172.22.76.126";
    region = 42;
  };
}
