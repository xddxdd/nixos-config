{
  tags,
  geo,
  ...
} @ args: {
  index = 6;
  tags = with tags; [qemu server];
  city = geo.cities."US Seattle";
  hostname = "38.175.193.201";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCumvNl3bmBuwLcKPsiHXt9hFLtZ6t9cXNmIkI1xvCslKvKzn8nss07yfHebX6it7CGWoKd/S4+Pp7eUoMBTiXFZYhNaTxd4Oy8BPGadWKzkzgXRoYe8cMOv8j+cW/zLf2UvNtGGG+J5qAZB6CtqB8s5qp4GBvlOIYXshyiSgrPRAjFxk+Je7w9kmC//G5gFiM55Yj/35OdYvw2kXKVc10ofqOBgs2X73CwI3bz2CmN0al3Vak2oYc8bjHu2zchyY1RgMptt6rYPCLdz9+J2bRj5yiFnYz6jV2B3RMzPxO+nRe4o7Wd76au6skTd+tk4M4gX+a44TE4o+41T+Y68ibe72wsnOYxkbE8SzMCS84olcXWuCxxB/hixYGFiZCNOnr19vnrEUQm9+TpJvRVgCWSrCTIm4uuW5z1CMyOrK8gC4owW/JnK2UhWT2yaUKcp3OpdSwSLpNWl0SURU81nNsCMAVUoWAIutReoC674vM+582yFuVyiDZK+HO+da4llsAEGSNppfS9X/WRo/0R4LIKtkLNEeEMZmLfjnqKgzlgwcmHrP0tGFz5OE2NK1MbULxEA0tWvRVXt3gYvbETexVndxAn6dlPA5Yln75LLZHoGkzk2LwRvgIoBAbHUUBpDlg90eKRD5NzuSep3g10CuozSbAgKqovtTtBvbijl0cWxw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKuko3UFE/n6VhkJbgKxb7IdbypXZgVTgAiLqIkYIst";
  };
  public = {
    IPv4 = "38.175.193.201";
    IPv6 = "2606:a8c0:3:415::a";
  };
  dn42 = {
    IPv4 = "172.22.76.119";
    region = 42;
  };
}
