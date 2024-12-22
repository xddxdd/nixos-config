{ tags, geo, ... }:
{
  index = 12;
  tags = with tags; [
    server
  ];
  city = geo.cities."CN Hong Kong";
  hostname = "20.2.172.177";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYlG3Z33ohRI9Qtu1GJZAwf+4sUlDBPAyBhlSAU9Y3dXvrM2qXR2IYAet8wtiyZA0WANgD0j6KUAMV8Sci7X5pZQlCnPG6Rz57Zv5IMrfuWk3rVzuGsM7yPnu3+RZHLRhDxIgkWkcOlY73kz+HTIME/I5DOAsEAtH6FbIAbYr4dC3YS+ROFtU6vrdqSLbHYufyL9XoAmTBpgPxb+ZeFIst/dy5Y8F4JyZNPg6xEUHqkf6B/qwCOzIbF5kfaG0e1nD6ZZzo4EjL77mFChSsfcNM3kdBFN306xm7NHex7Etle/A6K35PYsntrfhRwDg/6NDdwjvB/DRpZxJ3IfXTZu9JZ3aS8Il+JvmjeT1L7XzNX5i0v5toYSozM6ajazNXWNRpIJi7F9AaHpVKXqHjd6EmcEsLF7EJHITXtX0hoI6bV2xkDzYvJ0VNKrlEW4haesRl78Jc97RQG1d4ChpVGmEUpIS5Bcm1UDHnJo1O7WYFWWcqoMpy1AHTyAl4aCFDFONS4hpTZsgzT8FqMk+IbHtFymP0xLTB77xtO8TkRVt3nqOAL/5FrFMZosI4eWuaOKwM1nvSCRx3yZVzeSYKHD8H0uBrFWQWz/FEh7d6fhJNkCUUtUbm5pgY3gdbwNZN5I166Eaz74j1HO0j1fVCZu4VoHOTY0DdG7fn1zDxTo3muQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIruh/vfux+WaGLUIYZmcYDs5TWKTm0Mvo13dcG7cvGb";
  };
  zerotier = "3acad43396";
  public = {
    IPv4 = "20.2.172.177";
  };
  dn42 = {
    IPv4 = "172.22.76.119";
    region = 52;
  };
}
