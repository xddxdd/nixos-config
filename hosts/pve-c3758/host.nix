{ tags, geo, ... }:
{
  index = 107;
  tags = with tags; [
    exclude-bgp-mesh
  ];
  city = geo.cities."US Seattle";
  cpuThreads = 8;
  hostname = "192.168.0.5";
  manualDeploy = true;
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsWK2M8OmKT47TtE34SaqvBReaCaDVDkzWFCUX9fwN4N1ZzKAO9fSnp1oJS0zRG8GPzkKsE20bwJe+RzjxHK0ExsnHxC+L5eW99PrOE74/cTyXD2nvXj1PVnD+Bk0Cz3vl0IKfvuTkUxlUgSADlTjSN6+gxUgXBk/THVsw4LxsaTr+iNWDuHqM8FPHYfxdjG6D0FDvPQdO8bkcGJq8iIADZxCc4/RBpfUvCvsl/qyqHFl53fRKeavRmkPi05FYkjp4s9FYBkx0gthgKIPx211pQlRyNwII/PXprVlPZAdIbf4i6Gk3ka6OyAoxPZz63sRl2PX/pMVDOwo1kFswdJyF0kUBSEpeHK826x4EGSKZsYLRz9JAZ5kwTYIDuQwFZoDRjJ2v6RCP/WiUZv/1Fz/0HQK8q1uU65cbxu8DgPrxDa+fbuKIyisFLUrcg+LRnDYJ5QSvmBCTtculDdWDYgGfQQoWsglb44Mm2qNVqlFQr8d/R/YPkROhTcffKPTAkI3m7fYED6rvhg8MuDMYnmOvR2Fhhfmu0xZPHNVXoOKCsnYRCnF+HaVT20iu2/nz7GP1Ix+Nc5WoMGQEvq62wK1FuWR5X2yIcJlLNMdHeTdIPoBGuSyfyHSgHNbclmPQJnM9koXoSu+QS+Zxnyb8znH0xZDRJ7V2AFi4kSANYn7d4w==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVVZlKt3hgDvEfZOSKIPxbiDis1TArv4jjKSggJYik4";
  };
}
