{ lib
, ...
}:

rec {
  containerIP = {
    netease = "2";
    grasscutter = "26";
    nginx-proxy = "43";
    yggdrasil-alfis = "52";
    powerdns-recursor = "53";
    coredns-authoritative = "54";
    coredns-knot = "55";
    coredns-client = "56";
    docker = "79";
    drone = "101";
    drone-github = "102";
    plausible = "138";
    wg-lantian = "192";
  };

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

  dnssecKeys = [
    "K0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa.+013+11807"
    "K10.127.10.in-addr.arpa.+013+53292"
    "K184_29.76.22.172.in-addr.arpa.+013+08709"
    "K96_27.76.22.172.in-addr.arpa.+013+41969"
    "Kasn.lantian.pub.+013+48539"
    "Kd.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa.+013+18344"
    "Klantian.dn42.+013+20109"
    "Klantian.eu.org.+013+37106"
    "Klantian.neo.+013+47346"
  ];

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

  port = {
    Whois = 43;
    DNS = 53; # CoreDNS public serving port
    DNSLocal = 54; # CoreDNS local-only service port
    DNSUpstream = 55; # CoreDNS DoT proxy port
    Gopher = 70;
    HTTP = 80;
    LDAP = 389;
    HTTPS = 443;
    LDAPS = 636;
    V2Ray.SocksClient = 1080;
    YggdrasilAlfis = 4244;
    IPFS.API = 5001;
    Radarr = 7878;
    IPFS.Gateway = 8080;
    Vault = 8200;
    Waline = 8360;
    Matrix.Public = 8448;
    Sonarr = 8989;
    Prometheus.Daemon = 9090;
    Transmission = 9091;
    Prometheus.AlertManager = 9093;
    Prometheus.NodeExporter = 9100;
    Prometheus.BirdExporter = 9324;
    Prometheus.EndlesshGo = 9322;
    Yggdrasil.Public = 13058;
    Yggdrasil.Multicast = 13059;
    FlareSolverr = 13191;
    ASF = 13242;
    NeteaseUnlock = 13301;
    Vaultwarden.HTTP = 13772;
    Vaultwarden.Websocket = 13773;
    Plausible = 13800;
    Konnect = 13877;
    qBitTorrent.WebUI = 13808;
    Minio.Listen = 13900;
    Minio.Console = 13901;
    Oauth2Proxy = 14180;
    WGLanTian.ForwardStart = 30010;
    WGLanTian.ForwardStop = 32559;
  };

  portStr = lib.mapAttrsRecursive (k: builtins.toString) port;

  reserved = {
    IPv4 = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.0.0.0/24"
      "192.0.2.0/24"
      "192.168.0.0/16"
      "198.18.0.0/15"
      "198.51.100.0/24"
      "203.0.113.0/24"
      "233.252.0.0/24"
      "240.0.0.0/4"
    ];

    IPv6 = [
      "2001:2::/48"
      "2001:20::/28"
      "2001:db8::/32"
      "64:ff9b::/96"
      "64:ff9b:1::/48"
      "fc00::/7"
    ];
  };

  stateVersion = "22.05";

  soundfontPath = pkgs: "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";

  tags = lib.genAttrs
    [
      "client"
      "low-ram"
      "nix-builder"
      "server"
      "x86_64-v3"
    ]
    (v: v);

  wanInterfacePrefixes = [
    "en"
    "eth"
    "henet"
    "venet"
    "wan"
    "wl"
    "wlan"
  ];

  zones = {
    DN42 = [ "dn42" "10.in-addr.arpa" "20.172.in-addr.arpa" "21.172.in-addr.arpa" "22.172.in-addr.arpa" "23.172.in-addr.arpa" "31.172.in-addr.arpa" "d.f.ip6.arpa" ];
    NeoNetwork = [ "neo" ];
    # .neo zone not included for conflict with NeoNetwork
    OpenNIC = [ "bbs" "chan" "cyb" "dns.opennic.glue" "dyn" "epic" "fur" "geek" "gopher" "indy" "libre" "null" "o" "opennic.glue" "oss" "oz" "parody" "pirate" ];
    Emercoin = [ "bazar" "coin" "emc" "lib" ];
    YggdrasilAlfis = [ "anon" "btn" "conf" "index" "merch" "mirror" "mob" "screen" "srv" "ygg" ];
    CRXN = [ "crxn" ];
  };
}
