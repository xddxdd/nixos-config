{ tags, geo, ... }:
{
  index = 17;
  system = "aarch64-linux";
  tags = with tags; [
    nix-builder
    server
  ];
  city = geo.cities."JP Tokyo";
  cpuThreads = 2;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEAA+slkz3zRc8PkpIE7J3ro+92B8kakYggOf/FVPD9";
  zerotier = "ca30a4a94e";
  hostname = "161.33.174.213";
  public = {
    IPv4 = "161.33.174.213";
    IPv6 = "2603:c021:8000:aaaa:4::1";
  };
  dn42 = {
    IPv4 = "172.22.76.189";
    region = 52;
  };
}
