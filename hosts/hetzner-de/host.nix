{
  tags,
  geo,
  ...
}:
{
  index = 14;
  tags = with tags; [
    public-facing
    qemu
    server
  ];
  system = "aarch64-linux";
  cpuThreads = 8;
  city = geo.cities."DE Nurnberg";
  ssh = {
    rsa = "AAAAB3NzaC1yc2EAAAADAQABAAACAQCo6QFijGZdiZKCu/ddjuCziap7pAt3JgZvN40ekG7HH20FGEF82Jf+f5fe0qBk11BM+DqIjZzbXg/E4W2fbqkGwNCxuqLt0jdJJmyB25j8UVLeSSQGJ+k4dRgj2TgD9uxvZT530+doVS3maZf5+sUvO4KMWAaRVHfJIqF1NTUHWWIyFwuvfWh/2iZg5lWkafWhGWUsYGmzmhPgWFo6SGAn/zVHon2lFCcqi8NpJQ/f7/VYg8aQhl0GbDOJWLQFrX3GN1/2kZfyZIoW0gaX9ZdicPE+atTIFY8nEpLK80mx83Toy7UBwWav6wNMv3jUoGiNxpodnMarOw3LijUCbku+NyY36kp7bmy4QZmElCMYQ0aBGofnlrVZxOdYmG9kd87B8IwFc/kvPCWqFM/3mrksI+E8JlV4AyEFGJHUluWnS4sh2/NnlITtCvKU3wPmThQGoD7jg3dVMfbFXMOZVfNDAzy2s/mw2Bt5N+KNtmoat2dVEIa0DINPRXEq1Td+fcmPRjEcaPRpZ6YuE1F8Rxz1Fnwf853fNb3NDGGgjGLPHruMBAKsR/ux8GEzUU7QALU/Y7i4TATF709czqcIQMv5QoCOrD9L753a3csb3zz7PLGWKeIZamKr+qv0vyV/c8UxFvd+xp2cPtFteHk3kjHCketQ3FVuM361oO6rCXd/qQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII0/Xn93xTjMcdYHlmQ7MBgN2bx3o5bLdcEauWyfNoX9";
  };
  zerotier = "6ae099ae13";
  public = {
    IPv4 = "159.69.30.238";
    IPv6 = "2a01:4f8:c2c:8bbf::1";
  };
  dn42 = {
    IPv4 = "172.22.76.115";
    region = 41;
  };
}
