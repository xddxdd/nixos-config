{
  tags,
  geo,
  ...
} @ args: {
  index = 6;
  tags = with tags; [server x86_64-v1];
  city = geo.cities."CA Montréal";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClxxprXEYNHdbrxA6P0vIzWqSaZ3/sbVacLdTolj5epwc/aklqXbBI5zDH4tac3RmEOBIVNW3PHMZcOAnwD0eo+WbCFw6qkckZBQFAAmroqI5RExonnXgTbuCqQld/kjVtmU/Wnf72yk/BQm8cWfmhPi0I9siERqkzV9lV0vow3jYPgUtA0u5kBU76iBU2X5VYv75Gim7/xC3Fe7c8Oo8LQQdMwSVfAJzC6tPMYQWo/BaDRQfHGyJqfVYq/BSCUhYev361P9gA+L0EMq3b+ohb2v2FqSwQnvbnAkWq4EVL4JpqJ8kboxGVCQTayz6kTu6BYwgvGmSKZo1/mlVEUrlbFK7hPlTH2THfR0ZLiNjJ1Ael1cjOdIRPG0EHhhafRAAYfaDRxO8UZqPg1XjzQCqmliQPBhxnr18VibRph3b+s8Xbi2prPvdPbIy4etZA3RJFbU9HyGoJxtFKWylJ/zeDoVIvdYC/6dtqTd22Aw8VNHein77RmVMInqZwVjvy7PFsnyFX2OnQk7hxghxMY7MkD1eg+Y5CuChkrV1y0pXUhczes44qMjYGkM5Zz5yRP1qLX3pyf1Sash7JDfeU9CoM2RUe1q36knNSwufia2tSUh2C1YxG9yTTxbB53NhcP4wukkmt4NG4XJWTTaX3typf0+ooNQUAB06Tal4vl0dBGw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICD/HKWrYGo0Ip5ktr4KOWLRg+FHkRkhEi8rfFf3RifQ";
  };
  public = {
    IPv4 = "104.152.209.126";
    IPv6 = "2602:ffd5:1:160::1";
  };
  dn42 = {
    IPv4 = "172.22.76.119";
    region = 44;
  };
}
