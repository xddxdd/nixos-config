{
  tags,
  geo,
  ...
} @ args: {
  index = 104;
  tags = with tags; [x86_64-v1];
  cpuThreads = 4;
  city = geo.cities."US Seattle";
  hostname = "192.168.0.207";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+h5ghxorbdud6/oCBo7lKh7WTIL16id5m67TdOfsVYntWayWA7ouvwEkHx13DFXNcGD/yfTq9PT9KkAiXk7zfiWx2tF4RFCqEa9X6PZfDii4gf8ENswS1ZnMthM6/87RQHtpzyorBFleFdS0TGamhEC1AV9OFwMk8ymqOq42jkQtFf8jjtAXtnx5JIMfR5QnOLG8oBAdZsz5NyLkKyB5J0fXFoyqpCkurSCuzKWmPkqyxy+WmIcrBgf7Kx1DsRnWDWmlNfuGr2a3SexpogoaU/PvcQ90ovWoWhsiU4mlzCa34NEEdeV5YtepB7libZLSL63EvWyC7qkwQQR2SQqYEZl5huO9M0mnKXgjA1Sglu4idSMqrwHjKlJE0W+oJvDy7DbY4HNHiOgQcVQdqCiVYVzrar7fuzotqpIQuum9jq0wJEfBJZbX8WmFbi/uXcYgPLOAPhsakQEsvdUS9r8QLxwMG0qbhByf+BQo20i0VJ0hdrDpTQ5lHF/kLbTJQ3s2QX7ZVZRzmLwlgw50MK3C9cJuriS/tab9hCDNuym5/ZfzyJiG+LuqOp0r2spi3YrbNNRu2OZzN0N1skX228yqvZTkdFtJDlVwyNKt+4pVPLT6iJ/E3VHV2MeC9KsubXlWQlIpDqcPjjxdjSo5Pfig7+OV8S0iLazTVTwVT6QHY/w==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjBBTtlrrqBSfPS+AMrmKIXqJ0Hlf0isl8tQkAqnNg8";
  };
  dn42 = {
    IPv4 = "172.22.76.118";
    region = 42;
  };
}
