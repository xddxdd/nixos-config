{ tags, geo, ... }:
{
  index = 9;
  tags = with tags; [
    qemu
    server
  ];
  hostname = "2a14:67c0:306:211::a";
  city = geo.cities."CN Hong Kong";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPteds3KTvIKldwFbcbKY7IAspKuScUwVmFTwUE15whzaASmGAhgJsGUwZtu2L/WD+lnJrdMPCBSrCkBJXDAdx+GOmu1AhBA2tGu9s/oqm2xib3uMKTmcZMdfliDpw0zMCBl0Ja/hbEuipekT47FwIwi7jroaQpEw3JbmHa4c4TA1KnQMzXvv1SpcrJjJQeokH7y9NFhkOiE0w+CfIoyuGGhQYsYzeQ+Ewi/pjXY4UjqIH+4oLo1i9XnvVfr/QywwNfCjlTc7PqWYDClw+hZ4ndE9Oa+AYejgMvLr18Pc7N1I3yIF7PK5KV9v/dGerTw2gZCkEOE5/kZ27w1YJOLblhq0AaOGhQEZPmjdrgTNLY/P688w+LKFSHpei+T16hBYQcDqqH5WG5/FzjD+Au1+c7LU1UP9r0FddSytIWfRqcSKhdH7GL54H/l/qEzJ+7HG48tQhxxocg/dB1EcUucI8PkCs8NqLAMDSmvbt6rIlO57uoB7ELYy/9DsJDT6enj+R/ax0mIV38m+JyZc31h911qScUM0oDZInTVDw5azC9cZ6KWF4qvenBEin/27kFCr1AnAA2jhSAvPw5uph0tGvT2OjS4HGpYHEa9tGZWYCZBDF5A6H+VXUnNo22IuSxdBO8vsr5DsatnlOMyVkeDP2RFLYMGG49xhwecWvyuICoQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBiZ0rtz7/Ge4NkaVYDCkm7KEjgXOkslc8HmFhOr86dX";
  };
  zerotier = "a863150d72";
  public = {
    IPv6 = "2a14:67c0:306:211::a";
  };
  dn42 = {
    IPv4 = "172.22.76.188";
    region = 52;
  };
}
