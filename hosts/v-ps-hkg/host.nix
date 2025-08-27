{ tags, geo, ... }:
{
  index = 1;
  tags = with tags; [
    dn42
    public-facing
    server
  ];
  city = geo.cities."CN Hong Kong";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChQcbvCQd/LwHhTC44LsjMBdR6Kv8RVXWWQN363niVrZiPjFkkNNH7eqzgzUjrlhZh/gkWEoAUoJUJ/YJFJVB6HfoubS3wFA54qzY3hkcHBCLEQXiW9rG8p41WJxdjduJrOboNWKsxsuhkwaP1xCK9SBJOII6/tEZGXg6Ajvi19qR6OqKC9n7Q0+fT16QNKUn8AOCinTYaKug8Zxlgw9cKHVmAuI9+g5gpEpBkbGZnflGnHDp9p7ZbAWHInek+9HgUd0Vc2fzLKDbteTz7uTL4tQyxatgdYSOQK5yFvHhVShCxOJNBk4W6cTjhrMHvz8AuG3O0jGdQNIhS0KMzI/d37w6n/S5hXCRQoHi1X48pc0z8Kqf6ej/aAoh8rejUz1SoZJR+y2KailFAYGX4dAYPolcIBVYt+RfLeclnmybapXrv+PcslZbBUkBncPm7rK+u0b5IV1o9PPBZHklsJlA7LVtOMAGvaH1j4ZQCrnRQo+IYL/4jSqC1vnM7XjARQDAKAxnoT7FwzKPUU3Or121Vw+WaI4kCZgzJZfrQHQU2BkKYeYn7nuWTkhn0qEdHomCIeoiPiuQnF+NNH/oN+pI53Uyflv+19DcTv4jV2gq0L5+ifXonYf0e9Eujql4Fai5Cltd71ee6wa/DagcpXMd1QDCmQCVuMkB/tFp7q45OJQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOr1Sq4OSSjirG3kVybjypj0s7nEtx4F23ISgxSRQvV";
  };
  zerotier = "c61df0c319";
  public = {
    IPv4 = "95.214.164.82";
    IPv6 = "2403:2c80:b::12cc";
  };
  dn42 = {
    IPv4 = "172.22.76.186";
    region = 52;
  };
}
