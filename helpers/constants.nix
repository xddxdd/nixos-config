{
  dn42 = {
    IPv4 = [
      "172.20.0.0/14"
      "172.31.0.0/16"
      "10.0.0.0/8"
      "169.254.0.0/16"
      "192.168.0.0/16"
      "224.0.0.0/4"
    ];

    IPv6 = [
      "fd00::/8"
      "fe80::/10"
      "ff00::/8"
    ];
  };

  emailRecipientBase64 = "Yjk4MDEyMEBob3RtYWlsLmNvbQo=";

  nix = {
    substituters = [
      # "s3://nix?endpoint=s3.xuyh0120.win"
      "https://cache.ngi0.nixos.org"
      "https://xddxdd.cachix.org"
      "https://colmena.cachix.org"
      "https://nixos-cn.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    trusted-public-keys = [
      # "nix:FXFCqBRF2PXcExvV31yQQHZTyRnIsnLZiHtu/i0xZ1c="
      "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
      "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "nixos-cn.cachix.org-1:L0jEaL6w7kwQOPlLoCR3ADx+E3Q8SEFEcB9Jaibl0Xg="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  stateVersion = "22.05";

  soundfontPath = pkgs: "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";

  wanInterfacePrefixes = [
    "en"
    "eth"
    "henet"
    "venet"
    "wl"
    "wlan"
  ];

  zones = {
    DN42 = [ "dn42" "10.in-addr.arpa" "20.172.in-addr.arpa" "21.172.in-addr.arpa" "22.172.in-addr.arpa" "23.172.in-addr.arpa" "31.172.in-addr.arpa" "d.f.ip6.arpa" ];
    NeoNetwork = [ "neo" ];
    # .neo zone not included for conflict with NeoNetwork
    OpenNIC = [ "bbs" "chan" "cyb" "dns.opennic.glue" "dyn" "epic" "fur" "geek" "gopher" "indy" "libre" "null" "o" "opennic.glue" "oss" "oz" "parody" "pirate" ];
    Emercoin = [ "bazar" "coin" "emc" "lib" ];
    YggdrasilAlfis = ["anon" "btn" "conf" "index" "merch" "mirror" "mob" "screen" "srv" "ygg"];
  };
}
