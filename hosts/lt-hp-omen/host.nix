{ tags, geo, ... }:
{
  index = 100;
  tags = with tags; [
    client
    i915-sriov
    nix-builder
  ];
  cpuThreads = 16;
  city = geo.cities."US Seattle";
  hostname = "127.0.0.1";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDE4CLCfkSGU7NMz4n5yp8AEdds7br0Ehe0e/RFCBz7wmqC6JeFgwapZefDwdI5av5UnBP1dqmi602OBF9yTCQ0yL1FLYTgkfWjGZSpRWOW69rQGsSGHMF/BExNQnVzmIrlMHlWtyQvDsI6tycMAiPBh2e2jcCzjGQSsHIE2d8TNN3XaA1Mht9dC7pAQqT3QUeYbUud2xWh0jCLLX+fLe9F41O9//TLLX/Lergf8Nxlu9BBM8l3t7JQBFq0QmzFSL+ODnlMCq/yEkXTOTNUNo9hzuLIr3qTX3jmYb4iF+WmeAfTcA1i0JWeMo/TilWhKsoBkYanIBCz9tctpqB2xFOWlC8UKXlgRwDRftDXTIrHMu2RvshB6bKxfV54yYAkMp7p/Alfq+4aYDjE10e0IRxB3AGsyVDH7eGWxbdDJSblu2zNaZfFmIARVU7Kc1bJHe05NmAOSwIparSh/ge4Nv3+i+ZQr6GPUv8ILHJEyn1kladwX0tubqXyR8caETe0FL0=";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZp2mN9BALoEjCyvAK27k5AZwOmQqU6ZWi+SXvYezBe";
  };
  zerotier = "9dfea6fa27";
  firewalled = true;
  dn42 = {
    IPv4 = "172.22.76.114";
    region = 42;
  };
}
