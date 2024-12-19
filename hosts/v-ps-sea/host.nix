{ tags, geo, ... }:
{
  index = 10;
  tags = with tags; [
    public-facing
    qemu
    server
    x86_64-v1
  ];
  city = geo.cities."US Seattle";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCLOsc1tgJ+UraXXY8vkB1JAlYU3QS2l2CU35MHsHuhauR7Bb+W0H9i+5I/wKfGYVNAd1wAiFBqTJzLQsw+om5QSX2abQkK96TNCON9J7ftMjRjBt2ww9ynmBHmuV12U3Nx/U/VTWj/p9wDqdKE6fpUziWJwxGi1adRSouzea7znLmeXCcOlsn2wcB1pReXS8hDA1V9A8DW83wNi1rBt1ry0jdEwuL8VtVgoVD99E9XycrIQeJpb7ZB60Gpze8UiIF4uVsz0hRcouuXF7lUMyKY/ImSZVbS8VsVTd8ADiRIujj45HbLtZ4dODzGbiU3/13lwg297QjbvGOCOQBVax4VCFBTFDyZpbcRd77NviFIiaL+G8nEn2gPeOV2Ev5s3gU4T1UncnX4Qru1piaGI/r3SfzZEeNhoivJ7pMuaLMnIDNQ3US1vUmdKrDB+fZRx3q/jYwdR/rl1aSf61kqLSFVkGuXawhUluHbUqWB6aRG8yAYj1gJIMBAn8gweM/DTCLI9bwpH4gAFdZJShq++3x7QqaK9fWGKH4O64C4g178F73Ya3R3stXltWpStXXHTmETJAKMqfxGRxm3w8Rpq4I2ZUx8ZkUYarw4bn4FXJcwrLSK2lDB1hYGzwVEayT0MHQ6P2xUK9GbhiKryY5OHP/bEF85Wdhc1alHRK6V0neHFw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKXYFTOUNHp3n1M/oPBhqrgAWCTJm7wys098P4NPzou";
  };
  zerotier = "4b1e8d0849";
  public = {
    IPv4 = "23.145.48.11";
    IPv6 = "2605:3a40:4::142";
  };
  dn42 = {
    IPv4 = "172.22.76.120";
    region = 44;
  };
}
