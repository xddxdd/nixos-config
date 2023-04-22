{
  tags,
  geo,
  ...
} @ args: {
  index = 14;
  tags = with tags; [public-facing server];
  hostname = "142.132.236.113";
  system = "aarch64-linux";
  cpuThreads = 8;
  city = geo.cities."DE Falkenstein";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4jwDVkKk17MC0ERMrNei8QQoeS32Uf1rRfemnFQeKyKovJqcIqtsqtbDH2D3pp+2HQmRcSKZ2tGeTCQYcZnOMQRUDeBQHnZbnoMCMH/Zbt2WUUayfwv/lvle6nzm94ggNx6Ups1RNJIs9sBp6l/a2pG8M78GjMy4qvnHrbqd2Yj0+aqQv9Lhf2wJzepp3Eh4aR8YMBE46bC5o/BACxQTpMBBY7Yz7UDO3FuMIOMdhM/zsSzIwyfZtIAKYRbhhnKPce2MMXTOByFd2TJKcwcreyVX75j0i2A0KmT/U/+JTsWtXSBQ1y5ywRXRuysri+HX8W5Abv3EtZaJwfHzDk7f2jJv5LT+qWe8iJVRWqMWV4UvoUgEWNOKlxKKs9m4A5AOP6dRexCHSnLl0C0NcSjwcCsr94PfT0rsjHJ7k7vF7Jf/cHtBByzrDaJtkXru9+WDOC8NsP7kBaTMAVx0w86XNomRuIRoNQzozP/Y5dlGtRxAHS+uSWgCPAix3Q3Y/r4skpaU4zjWs9hN4+qwmM3vJcV+b7zxqB6e0Bn1VQJScgKpv0+87rZ3P7xITbiHN8aqmAvY45WNJn/32nI+4N/LMPQmv05dDMt2bWIOtKcdEpF85slOUo8XdasA1GLeCgNkFMItrdGOsaDfGaSjLhe8nmLH/lqo92Tbdf86lTpaIMw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDqSBT1rjkBS1fviSAAh+dP/JDhM3m4COVI6O8VTyXR0";
  };
  public = {
    IPv4 = "142.132.236.113";
    IPv6 = "2a01:4f8:c012:6530::1";
  };
  dn42 = {
    IPv4 = "172.22.76.118";
    region = 41;
  };
}
