{ tags, geo, ... }:
{
  index = 6;
  tags = with tags; [
    ipv4-only
    server
  ];
  hostname = "52.229.162.161";
  city = geo.cities."CN Hong Kong";
  cpuThreads = 2;
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqbBvVUqmS5ffYSF/8nLG3M/RCYGm4Ai3JLhxLmQvut";
  zerotier = "5dfeee16a5";
  public = {
    IPv4 = "52.229.162.161";
  };
  dn42 = {
    IPv4 = "172.22.76.116";
    region = 52;
  };
  additionalRoutes = [
    "168.63.129.16/32" # Azure private DNS server
  ];
}
