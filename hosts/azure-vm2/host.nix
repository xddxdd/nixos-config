{ tags, geo, ... }:
{
  index = 12;
  tags = with tags; [
    server
  ];
  hostname = "20.2.37.29";
  city = geo.cities."CN Hong Kong";
  ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIruh/vfux+WaGLUIYZmcYDs5TWKTm0Mvo13dcG7cvGb";
  zerotier = "3acad43396";
  public = {
    IPv4 = "20.2.37.29";
  };
  dn42 = {
    IPv4 = "172.22.76.119";
    region = 52;
  };
  additionalRoutes = [
    "168.63.129.16/32" # Azure private DNS server
  ];
}
