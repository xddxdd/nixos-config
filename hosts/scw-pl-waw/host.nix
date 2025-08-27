{ tags, geo, ... }:
{
  index = 16;
  tags = with tags; [
    low-disk
    server
  ];
  city = geo.cities."PL Warsaw";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDz81hbYHPwtoZtvIcytc1uITMKDrcUDuxPrlqhT4SGEb61sRb4enCsCgC8vzbekaZqGv+QQ0eapGc84YfPIcG1aH02S+SyDvENxCbMg8+WSQJLHsvj/RjttQ/bnBnUYqX/hezCfeSj3tcE432GHTD+FBxBGUW+7wNF7fneR83mzBYNP2x9tHepXxduwZ41EqXdLGAtaT7R/JLpocYCN8F83Yob+HgoR0+eg2Rp6mcW/l0hV43eb44v4eXy4/FtogENtC8OpUUtw5EbzJ0tvNI+JiJOyJN2VxPKIBvZK6X5NpAz0e+5Zlr6Cn/gjyGapKkz9eaNNN4GHMSOcvO5CVs97MXA0/9R8ZGNz+EgLg8gpGMqv0FGQLUlDOV5MCmfmQwwWbYgcftCr2yOPs7UcdOOtxQI4kenr51ToVPp/Ggd7OH9ROfIfGvd0X4SrvxUDzWg19lAc+fghKJ//hW0xvdR5kWsjstGTaAnmKOUlM/JRf570ImQ2wI7C5GXoXhKNjNrVlbJf8oI1vw6m9l4eHL3xIrm+8kInYONuK9xZNnsDzSHpX5H27nlTBkHTfKjHMrHPbrHVXarHDoDDvRNcTW3RvKUmguSOmWideVM62bIN7RARLyQ5McY/HBCEMOO8qxH18yB27a6j8pAq4U3ZbJqb/xhqphFtof0llK9/aW6ww==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCz8ucv4kJLTAK9eu+hoXyMINo1Lfm263wske36psS4";
  };
  zerotier = "7c53e2bfd6";
  public = {
    IPv6 = "2001:bc8:1d90:18d1::1";
  };
  dn42 = {
    region = 41;
  };
}
