{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  age.secrets.dn42-pingfinder-uuid.file =
    inputs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
  services."dn42-pingfinder".uuidFile = config.age.secrets.dn42-pingfinder-uuid.path;

  services.dn42 = {
    "24kcsplus" = {
      remoteASN = 4242421347;
      latencyMs = 5;
      tunnel = {
        type = "wireguard";
        localPort = 21347;
        remoteAddress = "103.42.31.208";
        remotePort = 22547;
        wireguardPubkey = "j+8lwUvUoGorFqjQWJJ8Mp7EWwqD4J4pLmd/HyizYls=";
      };
      addressing = {
        peerIPv4 = "172.23.205.99";
        peerIPv6LinkLocal = "fe80::1347";
      };
    };
    arnie97 = {
      remoteASN = 4242420977;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20977;
        remoteAddress = "129.226.101.106";
        remotePort = 22547;
        wireguardPubkey = "WhRf0cjwcOTM408+OKHFmVmA1i2d7mud9bmMCACLdVY=";
      };
      addressing = {
        peerIPv4 = "172.20.128.198";
        peerIPv6LinkLocal = "fe80::977";
      };
    };
    calvin = {
      remoteASN = 4242423166;
      latencyMs = 38;
      tunnel = {
        type = "wireguard";
        localPort = 23166;
        remoteAddress = "129.226.220.11";
        remotePort = 22547;
        wireguardPubkey = "5Il537C8jOaagWSog7bZXYaQLSn3GVBMNLtdWkKlD28=";
      };
      addressing = {
        peerIPv4 = "172.22.138.32";
        peerIPv6LinkLocal = "fe80::3166";
      };
    };
    chuangzhu = {
      remoteASN = 4242423632;
      latencyMs = 36;
      peering.mpbgp = true;
      mode = "flapping";
      tunnel = {
        type = "wireguard";
        localPort = 23632;
        remoteAddress = "ilama.link.melty.land";
        remotePort = 22547;
        wireguardPubkey = "9jmYu2YVnYc0zHTkFojzBQgVALUrIiYhq93TCb5qXDY=";
      };
      addressing = {
        peerIPv4 = "172.23.36.33";
        peerIPv6LinkLocal = "fe80::3632";
      };
    };
    huiliang = {
      remoteASN = 4242422928;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 22928;
        remoteAddress = "163.197.221.227";
        remotePort = 22547;
        wireguardPubkey = "ynDLxHffIXUk4b0Wxiu1qUCacRUluRWT759PHdOQPVY=";
      };
      addressing = {
        peerIPv4 = "172.22.78.98";
        peerIPv6LinkLocal = "fe80::2928";
      };
    };
    iedon = {
      remoteASN = 4242422189;
      latencyMs = 60;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22189;
        remoteAddress = "172.93.221.127";
        remotePort = 22191;
        wireguardPubkey = "TNmCdvH0DuPX0xxS6DPHw/2v3ojLa5kXIT/Z4Tpx+GY=";
      };
      addressing = {
        peerIPv4 = "172.22.66.52";
        myIPv6 = "fdbc:f9dc:67ad::8b:c606:ba01";
        peerIPv6 = "fd42:4242:2189:ee::1";
      };
    };
    jasonxu = {
      remoteASN = 4242423658;
      latencyMs = 4;
      tunnel = {
        type = "wireguard";
        localPort = 23658;
        remoteAddress = "123.254.109.25";
        remotePort = 22547;
        wireguardPubkey = "DiFXOjt1vOsisPKx7ncUwLvvxfvWF4VLqNOGO6TQMAw=";
      };
      addressing = {
        peerIPv4 = "172.20.193.2";
        peerIPv6 = "fd4e:d0:d38d::2";
      };
    };
    jerry = {
      remoteASN = 4242423618;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23618;
        remoteAddress = "05.dyn.neo.jerryxiao.cc";
        remotePort = 50092;
        wireguardPubkey = "GKLUwyY+FV+zqUZWFAknSzNGAg5LgtvS8o5y2PHHJFA=";
      };
      addressing = {
        peerIPv4 = "172.20.51.100";
        peerIPv6LinkLocal = "fe80::2548";
      };
    };
    kaikai = {
      remoteASN = 4242421488;
      latencyMs = 55;
      tunnel = {
        type = "wireguard";
        localPort = 21488;
        remoteAddress = "4.tanuki.koala.gq";
        remotePort = 22547;
        wireguardPubkey = "HVgivr3Ih0e/UusUwyvmNmwpK1gI2HH0FP/CxNvtQjE=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::605";
      };
    };
    kioubit = {
      remoteASN = 4242423914;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23914;
        remoteAddress = "hk1.g-load.eu";
        remotePort = 22547;
        wireguardPubkey = "sLbzTRr2gfLFb24NPzDOpy8j09Y6zI+a7NkeVMdVSR8=";
      };
      addressing = {
        peerIPv4 = "172.20.53.105";
        peerIPv6LinkLocal = "fe80::ade0";
      };
    };
    kskb = {
      remoteASN = 4242421817;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21817;
        remoteAddress = "4.hk.kskb.eu.org";
        remotePort = 22547;
        wireguardPubkey = "jxCsSXtUSVjaP+eMWOyRsHg3JShQfBFEtyssMKWQaS8=";
      };
      addressing = {
        peerIPv4 = "172.22.77.47";
        peerIPv6LinkLocal = "fe80::42:1817:1";
      };
    };
    liangjw = {
      remoteASN = 4242420604;
      latencyMs = 37;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20604;
        remoteAddress = "sgp1.dn42.cas7.moe";
        remotePort = 22547;
        wireguardPubkey = "R8iyaSzF6xx/t4+1wKlYWZWyZOxJDCXlA2BE3OZnsAY=";
      };
      addressing = {
        peerIPv4 = "172.23.89.1";
        peerIPv6LinkLocal = "fe80::604";
      };
    };
    libecho = {
      remoteASN = 4242421604;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21604;
        remoteAddress = "hk1.vm.libecho.top";
        remotePort = 22547;
        wireguardPubkey = "hQgRGnAP4xBHym+R/jf7ScjGbBDz5RXi5gF6CF7RiWg=";
      };
      addressing = {
        peerIPv4 = "172.22.111.97";
        peerIPv6LinkLocal = "fe80::1604";
      };
    };
    marek = {
      remoteASN = 4242422923;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22923;
        # IPv6 high latency
        # remoteAddress = "herzstein.mk16.de";
        remoteAddress = "103.73.66.184";
        remotePort = 52547;
        wireguardPubkey = "kJ3jo/7Od0Jy/7ae2LqFYMWMhvc5QiUttRtN+u3YfwE=";
      };
      addressing = {
        peerIPv4 = "172.22.149.227";
        peerIPv6LinkLocal = "fe80::2925";
      };
    };
    purofle = {
      remoteASN = 4242422886;
      latencyMs = 3;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22886;
        remoteAddress = "137.116.166.197";
        remotePort = 22547;
        wireguardPubkey = "jzHrpkgwV7wVzK2xVTWLGQ16Lti80pRHF9fvZ+CX6Ag=";
      };
      addressing = {
        peerIPv4 = "172.23.90.96";
        peerIPv6LinkLocal = "fe80::2886";
      };
    };
    rhinelab = {
      remoteASN = 24124;
      # Unknown latency
      latencyMs = 4;
      tunnel = {
        type = "gre";
        remoteAddress = "103.46.184.68";
      };
      addressing = {
        myIPv4 = "172.20.232.193";
        peerIPv4 = "172.20.232.194";
      };
    };
    ricky = {
      remoteASN = 4242422458;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22458;
        remoteAddress = "cn-hkg-a.nodes.pigeonhole.eu.org";
        remotePort = 22547;
        wireguardPubkey = "9O4ABGmh+EXPnOynhW60aByE3qorcV7UsAC9n55g6CQ=";
      };
      addressing = {
        peerIPv4 = "172.22.145.18";
        peerIPv6LinkLocal = "fe80::2458";
      };
    };
    rtxcat = {
      remoteASN = 4242423608;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 23608;
        remoteAddress = "89.185.30.137";
        remotePort = 22547;
        wireguardPubkey = "Rh29mLHDmFzlHYX7yatU1TGzC9L8ygQo8UTn+JNQOyw=";
      };
      addressing = {
        peerIPv4 = "172.21.85.161";
      };
    };
    rubick = {
      remoteASN = 4242423451;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 23451;
        remoteAddress = "103.172.135.171";
        remotePort = 22547;
        wireguardPubkey = "3RiYYcOW4AJeO5RRMezDHjDCOGKjUz/1lmdpVHcdSkc=";
      };
      addressing = {
        peerIPv4 = "172.20.165.192";
        peerIPv6LinkLocal = "fe80::3451";
      };
    };
    sernet = {
      remoteASN = 4242423947;
      latencyMs = 3;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23947;
        remoteAddress = "hk1.dn42.sherpherd.top";
        remotePort = 22547;
        wireguardPubkey = "Lz/SPcnKfbp4Z6LW7gysFxhyJXfyoett18r3kvlZcBY=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::3947:1";
      };
    };
    skyone = {
      remoteASN = 4242420811;
      latencyMs = 3;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20811;
        remoteAddress = "hk1.dn42.skyone.dev";
        remotePort = 42547;
        wireguardPubkey = "acuXU491Lw4iswEm6PWhLcyeeSK1k7nKP4II8w2LK3s=";
      };
      addressing = {
        peerIPv4 = "172.22.107.65";
        peerIPv6LinkLocal = "fe80::26cf";
      };
    };
    sunnet = {
      remoteASN = 4242423088;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23088;
        remoteAddress = "hk1-cn.dn42.6700.cc";
        remotePort = 22547;
        wireguardPubkey = "rBTH+JyZB0X/DkwHByrCjCojxBKr/kEOm1dTAFGHR1w=";
      };
      addressing = {
        peerIPv4 = "172.21.100.192";
        peerIPv6LinkLocal = "fe80::3088:192";
      };
    };
    syc = {
      remoteASN = 4242420458;
      latencyMs = 3;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20458;
        remoteAddress = "cn-intl1.dn42.huajitech.net";
        remotePort = 22547;
        wireguardPubkey = "WmKjRCtf9ZlIDkSuEOrjk5B7YdRZNGhhlbfz2waDAgQ=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::458";
      };
    };
    tech9 = {
      remoteASN = 4242421588;
      latencyMs = 54;
      tunnel = {
        type = "wireguard";
        localPort = 21588;
        remoteAddress = "jp-tyo01.dn42.tech9.io";
        remotePort = 54006;
        wireguardPubkey = "unTYSat5YjkY+BY31Q9xLSfFhTUBvn3CiDCSZxbINVM=";
      };
      addressing = {
        peerIPv4 = "172.20.16.145";
        myIPv6LinkLocal = "fe80::100";
        peerIPv6LinkLocal = "fe80::1588";
      };
    };
    william = {
      remoteASN = 4242422331;
      latencyMs = 36;
      tunnel = {
        type = "wireguard";
        localPort = 22331;
        remoteAddress = "103.83.156.22";
        remotePort = 22547;
        wireguardPubkey = "I5yRgHFY+qfkRwT6UpVBsUIiA5hmEOv1cU2licfrokw=";
      };
      addressing = {
        peerIPv4 = "172.23.131.206";
        peerIPv6 = "fd62:c9e2:af95:206::1";
      };
    };
  };
}
