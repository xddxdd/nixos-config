{ tags, geo, ... }:
{
  index = 13;
  tags = with tags; [
    low-disk
    qemu
    server
  ];
  hostname = "2001:bc8:710:ebe0::1";
  city = geo.cities."FR Paris";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDB8qtz/qMyIMXd7R1PmQROlUple2aBDBitSdZu1z0cV2L1HYdpdsDPTID8J3c43hfi3PqdV9hXlS4fKn9XExH9KRGSh8fcQB4ajSgWrBw8Eu7HXypaluWKsd040HD4SnVpUuuCOA9Tx98a62c2FJQYkjDFsS2uYwfiPShMQR4TSKVyZVCjVxzashfTZxDYMuvovTKAXIxUqCyLENJSri0YHxn+s7kT7T9g7/ccxVw1XVFjYHILTIejkvqvxaMMeFbyXdiZ0NjWZbcdM/2mhqKaJKKWWB17E/Cpod0kM0WZjRO+9ddOy9eAAOIOQSRnWJD1chaM0c+RW0+euJTw8ZFjG/6r4VoCA6chyY2qgnI8ichJbSesbdgXi3MtwYbJI6qIYJNS/G6dqUO3SUOqp4Jdb84id7uO6cv0xI3FuuePCvczCMlx1lGEmr755bkMVNTBywYLjLBA2a8QzpGCX0puguPUI5HzWxSXYI3Wc2l0+zNemIfbtg1hoJ58I/2IT6AliyjZibRoes/54lD2DzGrYkixoIcgHZRDK4QOxfhCrDGrGaYtSDOmJ3UirC/YsCmqTMuvBBQy7jX85L7Rt1jADbjZqZqUn3sQnaFErsCOBBJWtDeMnAlwqENO61vO2gVGJFLZVUMlpdd3S+54k3jlJLcao0Qa5z2V64vAyNnL6Q==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBLbqWpSZzdL4omMvwTgXoOsvkzUNgjAJNw5tMMQ0ch";
  };
  zerotier = "8d7a80a781";
  public = {
    IPv6 = "2001:bc8:710:ebe0::1";
  };
  dn42 = {
    region = 41;
  };
}
