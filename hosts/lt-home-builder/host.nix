{ tags, geo, ... }:
{
  index = 103;
  tags = with tags; [
    exclude-bgp-mesh
    nix-builder
    qemu
  ];
  cpuThreads = 64;
  city = geo.cities."US Seattle";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDUn6lZ8yEfnygV8y/TLUcb3t7A1fxkEMyWTdGtqXPGYacjQhKZa4w87Cjdn5rR+g6Y/pVtXKMd9xz4VfeP3xodnZeoyBBq0Zppb2OnJsXzC5aBN1qklrGXqParKIOpOCmMxhQUCU1llpDQcpWBYGozZe5hdxlKrsw7BMXbqkWffqHJO7HxoT/iIEyGVqcQ13OH4By21uhqoHNJa9odOKWsPKf/BLiU7SCDDiDvgpZLzQgb5Lfk/OZPANUC4Ne2qy31odrlWZJPGovA7oMDqrgt0e1cZoow1Fbcd0/dtebBYN1rCw6lzcAlu5vTD2j75DBq/EENYVHVc03APe64NteRvB2qCxReReXtEk0/MqM6fjLACJ7BlLWsztwjJ3TQbTqmbeduHcwvzMOuBK69thm/sgor6Wc/SArDd7BVsOk70lwLL5LE7RrI/xI0upss6oQug7CmPW6BPqONkMFgbF+8SFceMNhJw+YuYMNyMIpVwzgUmFwyZhY/nOmxeFX8yLO6N8Y3/II4B1s5XtJTkkcABpWZK5zrm+Dr9A3mLCrXt/36B3bo4o/nXJ3aFQc1vf3ywIKNqXl8bdBR6gn+soNHVSmi6dNpvy4u9kMtO34/TOo4o4zjR6+nQAQDeUMVDVCUywFzVjlxTcTwg4+uRHhWzP9BGkpUNZZqVxvqx7wQfQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMi22OSbQGOsXgYWtfMTkHB9IS1y0EKDfrQRqvafAeKN";
  };
  zerotier = "3030836111";
}
