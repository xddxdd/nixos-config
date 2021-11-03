{ config, ... }:

{
  services.dn42 = {
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
    burble = {
      remoteASN = 4242422601;
      latencyMs = 2;
      tunnel = {
        type = "wireguard";
        localPort = 22601;
        remoteAddress = "dn42-hk-hkg1.burble.com";
        remotePort = 22547;
        wireguardPubkey = "pYZJfGrs/PesUrEdvPUikaOi895D8Tpaho7VFSyybW0=";
      };
      addressing = {
        peerIPv4 = "172.20.129.179";
        peerIPv6LinkLocal = "fe80::42:2601:23:1";
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
    # clarissa = {
    #   remoteASN = 4242420998;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 20998;
    #     remoteAddress = "104.143.37.4";
    #     remotePort = 22547;
    #     wireguardPubkey = "QzCLXmD0YarOGZs3d0+yB97hkmIgfMGnxeMZ1NBuRAw=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.20.138.1";
    #     peerIPv6LinkLocal = "fe80::1910:cd02";
    #   };
    # };
    dadafox = {
      remoteASN = 4242421060;
      latencyMs = 3;
      tunnel = {
        type = "wireguard";
        localPort = 21060;
        remoteAddress = "cdn1.panduanbox.top";
        remotePort = 22547;
        wireguardPubkey = "sUmbo0a0WqWb8HnDFzbzkuRRmkQuR+Lo1gy4lVAIH1Y=";
      };
      addressing = {
        peerIPv4 = "172.21.110.65";
        peerIPv6LinkLocal = "fe80::1060";
      };
    };
    fixmix = {
      remoteASN = 4242421876;
      latencyMs = 3;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21876;
        remoteAddress = "47.242.164.161";
        remotePort = 22547;
        wireguardPubkey = "MCSKqsd4C5CGAlyvpmrt2Tg/F+7XkRWk2gWd6raOh0I=";
      };
      addressing = {
        peerIPv4 = "172.22.66.52";
        peerIPv6LinkLocal = "fe80::1876";
      };
    };
    iedon = {
      remoteASN = 4242422189;
      latencyMs = 60;
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
    kskb = {
      remoteASN = 4242421817;
      latencyMs = 35;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21817;
        remoteAddress = "4.tw.kskb.eu.org";
        remotePort = 22547;
        wireguardPubkey = "jxCsSXtUSVjaP+eMWOyRsHg3JShQfBFEtyssMKWQaS8=";
      };
      addressing = {
        peerIPv4 = "172.22.77.33";
        peerIPv6LinkLocal = "fe80::42:1817:1";
      };
    };
    # lemonrain = {
    #   remoteASN = 4242420226;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 20226;
    #     remoteAddress = "43.129.25.46";
    #     remotePort = 22547;
    #     wireguardPubkey = "YEsUlWDYcptT5tWbVVm16Jc5s3kSX6Yy7f8kVOEGBy4=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.23.226.1";
    #     peerIPv6LinkLocal = "fe80::226";
    #   };
    # };
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
    # monica = {
    #   remoteASN = 4242421240;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 21240;
    #     remoteAddress = "45.249.88.187";
    #     remotePort = 22547;
    #     wireguardPubkey = "Nrjwh6Zyqyj32/N7x/4hyEeMEiB2ED1ctRrX8rDxPB4=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.20.19.160";
    #     peerIPv6LinkLocal = "fe80::216:3eff:fef0:5e15";
    #   };
    # };
    neochen = {
      remoteASN = 4201270000;
      latencyMs = 55;
      peering.network = "neo";
      tunnel = {
        type = "wireguard";
        localPort = 30000;
        remoteAddress = "neovax.neocloud.tw";
        remotePort = 65402;
        wireguardPubkey = "48rktNreIKMw9zxwRtwgU6pQKJa3PF6RAimraZqYQFc=";
      };
      addressing = {
        myIPv4 = "10.127.10.1";
        peerIPv4 = "10.127.2.22";
        myIPv6LinkLocal = "fe80::10";
        peerIPv6LinkLocal = "fe80::2:22";
      };
    };
    # racime = {
    #   remoteASN = 4242423855;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 23855;
    #     remoteAddress = "45.32.40.68";
    #     remotePort = 22547;
    #     wireguardPubkey = "0sCpF4O4A0G/9uUCnEUh+U45oRwgn1i8dfug+M2iBGs=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.20.148.98";
    #     peerIPv6LinkLocal = "fe80::3855:98";
    #   };
    # };
    # rfchou = {
    #   remoteASN = 4242423878;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 23878;
    #     remoteAddress = "203.23.128.129";
    #     remotePort = 22547;
    #     wireguardPubkey = "zlGxgmyLlpD3xOlD+S4jViwyhKwZB3qNXfq7C85yDSU=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.20.238.129";
    #     myIPv6 = "fdbc:f9dc:67ad::8b:c606:ba01";
    #     peerIPv6 = "fd6d:3f59:4c68::2";
    #   };
    # };
    ruixuan = {
      remoteASN = 4242422433;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22433;
        remoteAddress = "119.28.43.229";
        remotePort = 22547;
        wireguardPubkey = "5YO6L7imDgNMlVCPAbjwEoEwtTBBM+fy+T5HYPK4zXk=";
      };
      addressing = {
        peerIPv4 = "172.23.90.33";
        peerIPv6LinkLocal = "fe80::100";
      };
    };
    sadan9 = {
      remoteASN = 4242422411;
      latencyMs = 54;
      tunnel = {
        type = "wireguard";
        localPort = 22411;
        remoteAddress = "89.31.125.47";
        remotePort = 52547;
        wireguardPubkey = "48t13/dCDplD6EzIHQ2Xq++SmB1oL9KrQRg1tLX342I=";
      };
      addressing = {
        peerIPv4 = "172.23.59.3";
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
    timo = {
      remoteASN = 4242421018;
      tunnel = {
        type = "wireguard";
        localPort = 21018;
        # DNS failure, passive only
        # remoteAddress = "hk1.dn42.126.ro";
        remotePort = 22547;
        wireguardPubkey = "+P5J00FPPCW+kHWnO710gJ9FwdMLzBaK7KxWj010ogE=";
      };
      addressing = {
        peerIPv4 = "172.21.90.62";
      };
    };
    tsingyao = {
      remoteASN = 4242423699;
      latencyMs = 2;
      tunnel = {
        type = "wireguard";
        localPort = 23699;
        # DNS failure, passive only
        # remoteAddress = "hk-cn.tsingyao.pub";
        remotePort = 23699;
        wireguardPubkey = "k5SukMZs//3U1YTH372hKQ8jenFxFZY4YLkDX7cWFRw=";
      };
      addressing = {
        peerIPv4 = "172.22.155.1";
        peerIPv6LinkLocal = "fe80::42:3699:1";
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
    # ykis = {
    #   remoteASN = 4242422021;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 22021;
    #     remoteAddress = "hkg-node.ykis.moe";
    #     remotePort = 42547;
    #     wireguardPubkey = "F16O673H/e4D6pA/LiJVQUVYUSLJS5lyjW+WHnpjTy8=";
    #   };
    #   addressing = {
    #     peerIPv6LinkLocal = "fe80::2021";
    #   };
    # };
  };
}
