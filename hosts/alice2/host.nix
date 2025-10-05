{ tags, geo, ... }:
{
  index = 17;
  tags = with tags; [
    server
    ipv6-only
    low-disk
    low-ram
  ];
  hostname = "2a14:67c0:105:10a::a";
  city = geo.cities."CN Hong Kong";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8ID7HwKALLeirbkT3CXz7qxvwK3pk3qfAGuz+oVdHQfajMOIqqQCPp14tTv6num0pneJjvft1KgaFJTrTzYifbLY5v9F9H6+5tu9Yu+z9OCufhlFFrPjfAlvsEqmlXog09GAulzACOO30A0vhEpxT2kx/qBj5lMbiSm9YMfwUxice6CEPP7NPITvOcaVXMctVnf5Rt5RhDJtdbYIJjEESRp0/MB7pe0vcpg4hmFZ5EftnovlKD/HSr6ogh7/XfIMEeSSzP4acKpMHVusN4MqVe7GZmpcxqeadm2THiCwNNsMXGqdJ6vEBx3QLtLPVcwTK9cmSJZV0OS/Euj+3SUS8yIJo/Em2J+6lTjDQGKkuOQ08eVqIeoTvIfhOkxlFLW/NfTc6E2rsDAlVcCXzKmu1b34VSV3BPFwBrHQeHHAwXByhLJAbisxbGaz5zy4Fs0+Wuu4vM6kk0aeLXG49LuaRuyWH64uh8QOnzch41bnKRCqNqIRMTizaK0xFGwHyKktQlRrI71RU5ksYrsRrknUkar274QqvdqbLpHQDe36028otwQWYnCvMv1TeAYPVNpiMLt9DCtfaM3ooXfo0FP25ugCQM4ZdRBzXZZ1sIfBi5VBc2+Pvgg5iWyDmkYftbtCP/JhZHTpSMSZD3yOJyLMf+Q7txsNjWGELtJeQbHhWEw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiCk13WHo2VksK6U083dWrSysE8IS47Z4RESE50W4vS";
  };
  zerotier = "81d0263128";
  public = {
    IPv6 = "2a14:67c0:105:10a::a";
  };
  dn42 = {
    IPv4 = "172.22.76.189";
    region = 52;
  };
}
