{ tags, geo, ... }:
{
  index = 19;
  tags = with tags; [
    ipv4-only
    server
  ];
  system = "aarch64-linux";
  hostname = "oracle-nlb.lantian.pub";
  sshPort = 22225;
  city = geo.cities."CN Hong Kong";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINii42sy+j25cciBZhBJevgXiZIlyqECQEIjyCh4FPjp";
  zerotier = "2fd8584e66";
  interconnect = {
    name = "azure-oci";
    IPv4 = "10.2.1.6";
  };
  dn42 = {
    IPv4 = "172.22.76.112";
    region = 52;
  };
  additionalRoutes = [
    "168.63.129.16/32" # Azure private DNS server
  ];
}
