{ tags, geo, ... }:
{
  index = 9;
  tags = with tags; [
    qemu
    server
  ];
  city = geo.cities."CN Hong Kong";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw1fEo3i7HViqekWReTW+jF7Nlw86ZYjez9zYq960PcuF9X/MaUjXCoUNuAs7km9AGc3RexPcX7sdth5qA2V7JH/KewARI2qiBZVCeX8DnSl27iVSkEeHFnoDQeSgrOnmQwd6N1ELpcJatGzWLA6FagobJm90HlbKW1uSwbh1TprDPtyFVLhaoyjIuTd+K3obCGZQiBY9Hmuiq0pTUM+PXgC4hRy5gsWnuLupDRSHDkPpAfXAND6decx6Xpx7GGtGQRbZ5xw0ZOPrphuVowagjMq7eQXivrc3S6LdqErdqnbVGUzV7EqJluRqWuH/j3XMUnrXxryJ/JpR7tMssc4xacRI0zD8J5jRGDDTvV+2RNarYC9bfHLVpdWHkELI1M2iNOehiYCzqO0ay5cVqEf3ynRe1HZIRp6Z7nI6dot/TjiQMx5+DGz1YTBvWL7NieZ9RjIKRus9qFZXDgK/8ZWylsVvRjemMv2Nno7l5js+7c5R9pfMO6NZiH4o8AJEus5Wx+M+A4hxXZAU7dGgcJPlhKCKZuIoVJTQnuctKN/ff+AeXNoZTM7MPdbNlzZ5ogrTXuCO9vXCohRlxXNBwGUYR4hUXF2nC+RBGCpYSUVypmpexRlbNpec6E6q+Q9BMltrQ/bRbGoNN4oateowFjiYS5uBqBUm6iXONWLNwUAdLpQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/8Bj5bOf+14ZrrvUdQNxBWjl0ZZ64D4wnUw9T5rK9N";
  };
  zerotier = "e3e49342bc";
  public = {
    IPv4 = "178.253.53.90";
  };
  dn42 = {
    IPv4 = "172.22.76.189";
    region = 52;
  };
}
