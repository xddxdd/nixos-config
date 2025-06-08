{ config, inputs, ... }:
{
  age.secrets.dn42-pingfinder-uuid.file =
    inputs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
  services."dn42-pingfinder".uuidFile = config.age.secrets.dn42-pingfinder-uuid.path;

  age.secrets.dn42-v-ps-hkg-h503mc-wg-psk.file = inputs.secrets + "/dn42/v-ps-hkg-h503mc-wg-psk.age";
  age.secrets.dn42-v-ps-hkg-immtele-wg-psk.file =
    inputs.secrets + "/dn42/v-ps-hkg-immtele-wg-psk.age";

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
    goforcex = {
      remoteASN = 4242421719;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21719;
        remoteAddress = "hk1.goforcex.top";
        remotePort = 22547;
        wireguardPubkey = "1GiY/gR40q1kUlMgLjWrFzDHTrRXIhNIYYVnecUTsUc=";
      };
      addressing = {
        peerIPv4 = "172.20.165.65";
        peerIPv6LinkLocal = "fe80::1719:65";
      };
    };
    h503mc = {
      remoteASN = 4242420298;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 20298;
        remoteAddress = "node2.ox5.cc";
        remotePort = 22547;
        wireguardPubkey = "KJDKnQIIL4er69E2uOkH1hM5QEwIIxiqEg62UJEdCGo=";
        wireguardPresharedKeyFile = config.age.secrets.dn42-v-ps-hkg-h503mc-wg-psk.path;
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::298";
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
    immtele = {
      remoteASN = 4242422488;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22488;
        remoteAddress = "78d8826d-e062-4893-b5f4-8af06da3f0ea.immtel.com";
        remotePort = 22547;
        wireguardPubkey = "+ES6XZEqmtYW559OS/hNuh2x0vWyzD2j1uqN/aRh/lg=";
        wireguardPresharedKeyFile = config.age.secrets.dn42-v-ps-hkg-immtele-wg-psk.path;
      };
      addressing = {
        myIPv6 = "fd46:1d76:e65e::fcde:3b13";
        peerIPv6 = "fd46:1d76:e65e::";
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
    jlu5 = {
      remoteASN = 4242421080;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21080;
        remoteAddress = "hkg.peer.highdef.network";
        remotePort = 22547;
        wireguardPubkey = "eedTHubyl5caiHH50GkknQa8SQtAF8q7aqmL26w5qSs=";
      };
      addressing = {
        peerIPv4 = "172.22.108.38";
        peerIPv6LinkLocal = "fe80::1080:38";
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
    leziblog = {
      remoteASN = 4242423377;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23377;
        remoteAddress = "hk1.peer.dn42.leziblog.com";
        remotePort = 22547;
        wireguardPubkey = "XaX6/G7EQbcjsrtlxNmDc/s/VSdTxtkBxZKB2JpWIHo=";
      };
      addressing = {
        peerIPv4 = "172.22.137.99";
        peerIPv6LinkLocal = "fe80::3377";
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
    liubei = {
      remoteASN = 4242421686;
      latencyMs = 3;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21686;
        remoteAddress = "hk-1.dn42.guet.eu.org";
        remotePort = 22547;
        wireguardPubkey = "ocG/0wXtmuXA9OF5pMVolBIsFfE1K3JILX3MC3J5pGI=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::1686";
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
    milu = {
      remoteASN = 4242421166;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21166;
        remoteAddress = "hk.dn42.milu.moe";
        remotePort = 22547;
        wireguardPubkey = "f9ZDh2U0UXxtEroHUYNWzaE6TZM3hhY3eLXQQpgkvBY=";
      };
      addressing = {
        peerIPv4 = "172.22.110.34";
        peerIPv6LinkLocal = "fe80::1166";
      };
    };
    misty = {
      remoteASN = 4242423895;
      latencyMs = 2;
      tunnel = {
        type = "wireguard";
        localPort = 23895;
        remoteAddress = "47.242.46.161";
        remotePort = 22547;
        wireguardPubkey = "NloT5zEAYDDzbAJkT16IyYoBwh5CMh3GWnccWsv6uHs=";
      };
      addressing = {
        peerIPv4 = "172.20.237.129";
        peerIPv6LinkLocal = "fe80::216:3eff:fe08:878d";
      };
    };
    mitt = {
      remoteASN = 4242420631;
      latencyMs = 2;
      tunnel = {
        type = "wireguard";
        localPort = 20631;
        remoteAddress = "hk0.dn42.mitt.fun";
        remotePort = 22547;
        wireguardPubkey = "tmvmR1Sy1VaWYHghXKPy9JU5jgJUSqpVd9YeTPtBewY=";
      };
      addressing = {
        peerIPv4 = "172.23.9.193";
        peerIPv6LinkLocal = "fe80::631";
      };
    };
    moo = {
      remoteASN = 4242423999;
      latencyMs = 25;
      tunnel = {
        type = "wireguard";
        localPort = 23999;
        remoteAddress = "203.217.110.41";
        remotePort = 32547;
        wireguardPubkey = "mGGBczSVKW+7UKRquI2GkbKrfxiATv9r4uF5WTP+vWI=";
      };
      addressing = {
        peerIPv4 = "172.22.144.64";
        peerIPv6 = "fd36:62be:ef51::1";
      };
    };
    potat0 = {
      remoteASN = 4242421816;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21816;
        remoteAddress = "hkg.node.potat0.cc";
        remotePort = 22547;
        wireguardPubkey = "Tv1+HniELrS4Br2i7oQgwqBJFXQKculsW8r+UOqQXH0=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::1816";
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
    rikka = {
      remoteASN = 4242421241;
      latencyMs = 2;
      tunnel = {
        type = "wireguard";
        localPort = 21241;
        remoteAddress = "8.120.70.225";
        remotePort = 22547;
        wireguardPubkey = "D81bsynyBaCkOpb55Hlrc2d/RSCfFOB7y5Xg+7kHd00=";
      };
      addressing = {
        peerIPv4 = "172.21.114.129";
        peerIPv6LinkLocal = "fe80::1241";
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
    saltwood = {
      remoteASN = 4242420222;
      latencyMs = 10;
      tunnel = {
        type = "wireguard";
        localPort = 20222;
        remoteAddress = "hk-1.dn42.saltwood.top";
        remotePort = 22547;
        wireguardPubkey = "0E4goqfQFKQu852QAqVSRfp9Si9MoTj8IllFiDG7gUc=";
      };
      addressing = {
        peerIPv4 = "172.20.142.2";
        peerIPv6LinkLocal = "fe80::222:2";
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
    stevie-hk = {
      remoteASN = 4242420337;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 20337;
        remoteAddress = "2400:8a20:112:1::38f";
        remotePort = 22547;
        wireguardPubkey = "jQAdLlfZ0mQBAAxIfSnltEBQQRIlf9/jMGWWPIOZY0Q=";
      };
      addressing = {
        peerIPv4 = "172.23.25.149";
        peerIPv6LinkLocal = "fe80::4337";
      };
    };
    stevie-sg = {
      remoteASN = 4242420337;
      latencyMs = 40;
      tunnel = {
        type = "wireguard";
        localPort = 30337;
        remoteAddress = "5.253.36.245";
        remotePort = 22547;
        wireguardPubkey = "TLb8PC/jYKK8wgFvahDxJux3Y3Hdo6yD74sRquPjX0o=";
      };
      addressing = {
        peerIPv4 = "172.23.25.134";
        peerIPv6LinkLocal = "fe80::4337";
      };
    };
    stormyang = {
      remoteASN = 4242421786;
      latencyMs = 3;
      tunnel = {
        type = "wireguard";
        localPort = 21786;
        remoteAddress = "hk.stormyang.com";
        remotePort = 22547;
        wireguardPubkey = "r95P2+zx2WEHIpw8JGpzVnEvR4WPQCyZV1KQWYpMPi8=";
      };
      addressing = {
        peerIPv4 = "172.21.83.129";
        peerIPv6LinkLocal = "fe80::8888";
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
    twilight = {
      remoteASN = 4242421309;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 21309;
        remoteAddress = "84.54.3.96";
        remotePort = 22547;
        wireguardPubkey = "5j8iv49pxNRzk8f6oRC6aymXQhtIGgcd8c6bCIOUeFQ=";
      };
      addressing = {
        peerIPv4 = "172.23.120.1";
        peerIPv6LinkLocal = "fe80::24f3:70ff:fe00:150";
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
    wnzztx = {
      remoteASN = 4242421894;
      latencyMs = 32;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21894;
        remoteAddress = "sg.dn42.pixlabx.com";
        remotePort = 22547;
        wireguardPubkey = "SIVAvYGipMzYjwwmHoRPIErSAQoVnmf+TR8IHZ0E9kI=";
      };
      addressing = {
        peerIPv4 = "172.20.44.161";
        peerIPv6LinkLocal = "fe80::1894";
      };
    };
    yakumo = {
      remoteASN = 4242420387;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 20387;
        remoteAddress = "hk2.l0.ink";
        remotePort = 22547;
        wireguardPubkey = "krJb3l8hypXbDs8h6zNw5QQy5zdwVsRKRm1g30KnYBU=";
      };
      addressing = {
        peerIPv4 = "172.20.44.129";
        peerIPv6LinkLocal = "fe80::387";
      };
    };
    zerowolf = {
      remoteASN = 4242420233;
      latencyMs = 4;
      tunnel = {
        type = "wireguard";
        localPort = 20233;
        remoteAddress = "hk2.l0.ink";
        remotePort = 22547;
        wireguardPubkey = "bWUSnkOds7fUAw/hh30QaORMjPi4+/PRWY8+AgqC6UU=";
      };
      addressing = {
        peerIPv4 = "172.20.6.64";
        peerIPv6LinkLocal = "fe80::233";
      };
    };
  };
}
