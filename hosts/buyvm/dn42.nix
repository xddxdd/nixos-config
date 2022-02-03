{ config, ... }:

{
  services.dn42 = {
    # alanyhq = {
    #   remoteASN = 4242420916;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 20916;
    #     remoteAddress = "de-fra.dn42.alanyhq.network";
    #     remotePort = 22547;
    #     wireguardPubkey = "MNAlzp0owhb8i7rdqpS1GxuSNlotV9lGFsxYb4IxWGI=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.22.123.4";
    #   };
    # };
    androw = {
      remoteASN = 4242422575;
      latencyMs = 16;
      tunnel = {
        type = "wireguard";
        localPort = 22575;
        remoteAddress = "par2.fr.androw.eu";
        remotePort = 22547;
        wireguardPubkey = "jlHp4FYZ69xdlaknLxBY3Uuv1xjsHoHH9qHe4b7BP2o=";
      };
      addressing = {
        peerIPv4 = "172.23.186.39";
        peerIPv6LinkLocal = "fe80::2575";
      };
    };
    baoshuo = {
      remoteASN = 4242420247;
      latencyMs = 13;
      tunnel = {
        type = "wireguard";
        localPort = 20247;
        remoteAddress = "eu1.dn42.as141776.net";
        remotePort = 22547;
        wireguardPubkey = "edTGR6Fs0rwAmGzWx/Zl6xxksYveRo+d75wWjxQYN0g=";
      };
      addressing = {
        peerIPv4 = "172.23.250.91";
        peerIPv6LinkLocal = "fe80::247";
      };
    };
    bastelfr = {
      remoteASN = 4242423668;
      latencyMs = 13;
      tunnel = {
        type = "wireguard";
        localPort = 23668;
        remoteAddress = "router01.bastelfreak.org";
        remotePort = 2547;
        wireguardPubkey = "0u/whhWEWu8dbQeCzx9bJ7JJ4j48WP1ZXsKG3K3gnGQ=";
      };
      addressing = {
        peerIPv4 = "169.254.0.5";
        peerIPv6LinkLocal = "fe80::beef:b";
      };
    };
    burble = {
      remoteASN = 4242422601;
      latencyMs = 6;
      tunnel = {
        type = "wireguard";
        localPort = 22601;
        remoteAddress = "dn42-de-fra1.burble.com";
        remotePort = 22547;
        wireguardPubkey = "e9xoCQKijX5r+/i3pvuB68rFzntIB3y8RnVH6V+qOSU=";
      };
      addressing = {
        peerIPv4 = "172.20.129.169";
        peerIPv6LinkLocal = "fe80::42:2601:31:1";
      };
    };
    ccf = {
      remoteASN = 4242422023;
      latencyMs = 13;
      tunnel = {
        type = "wireguard";
        localPort = 22023;
        remoteAddress = "185.196.220.38";
        remotePort = 22547;
        wireguardPubkey = "Fexv40BO3nCDIPyFytI0TWmN7XqBuLsFR+EItUKDn24=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::2023";
      };
    };
    dgy = {
      remoteASN = 4242420826;
      latencyMs = 48;
      tunnel = {
        type = "wireguard";
        localPort = 20826;
        remoteAddress = "ru.dn42.dgy.xyz";
        remotePort = 22547;
        wireguardPubkey = "Y8E2cd2DKr7hZ3qs1WgU+2l+qWHaOxw4vFPAGevpiW0=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::826";
      };
    };
    durlej = {
      remoteASN = 4242422033;
      latencyMs = 26;
      tunnel = {
        type = "gre";
        remoteAddress = "80.211.240.147";
      };
      addressing = {
        peerIPv4 = "172.20.129.169";
      };
    };
    fixmix = {
      remoteASN = 4242421876;
      latencyMs = 11;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21876;
        remoteAddress = "157.90.166.124";
        remotePort = 22547;
        wireguardPubkey = "rlfzxSL24UfKvl3cZsHcUr+i3MtG13tu8PRdDqOX3A0=";
      };
      addressing = {
        peerIPv4 = "172.22.66.59";
        peerIPv6LinkLocal = "fe80::1876";
      };
    };
    gareth = {
      remoteASN = 4242423937;
      latencyMs = 35;
      tunnel = {
        type = "gre";
        remoteAddress = "217.155.5.231";
      };
      addressing = {
        peerIPv4 = "172.23.162.97";
      };
    };
    # gfa = {
    #   remoteASN = 4242421097;
    #   tunnel = {
    #     type = "gre";
    #     localPort = 21097;
    #     remoteAddress = "dn42-nl-2.4679.ar";
    #     remotePort = 52547;
    #     wireguardPubkey = "iYvucYTTYVSketQvKkRuG5PKEE/UgpxSKZWSX0CUuzk=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.21.68.29";
    #     peerIPv6LinkLocal = "fe80::29:100";
    #   };
    # };
    # gregoire = {
    #   remoteASN = 4242421789;
    #   tunnel = {
    #     type = "gre";
    #     localPort = 21789;
    #     remoteAddress = "217.12.209.150";
    #     remotePort = 22547;
    #     wireguardPubkey = "ifxB+zSOdT5vJ/HfdXjvphy962rfezrA9CWYe4ISTgE=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.21.93.97";
    #     peerIPv6LinkLocal = "fe80::17:89";
    #   };
    # };
    iedon = {
      remoteASN = 4242422189;
      latencyMs = 5;
      tunnel = {
        type = "wireguard";
        localPort = 22189;
        remoteAddress = "45.138.97.164";
        remotePort = 22192;
        wireguardPubkey = "FHp0OR4UpAS8/Ra0FUNffTk18soUYCa6NcvZdOgxY0k=";
      };
      addressing = {
        peerIPv4 = "172.23.91.125";
        myIPv6 = "fdbc:f9dc:67ad::20:5549:a809";
        peerIPv6 = "fd42:4242:2189:e9::1";
      };
    };
    jerry = {
      remoteASN = 4242423618;
      latencyMs = 12;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23618;
        remoteAddress = "nl.neo.jerryxiao.cc";
        remotePort = 50092;
        wireguardPubkey = "+1HE1FMRhL/zNnLO50Q4VmRQXvwe2M7Kky0Xgdv//HQ=";
      };
      addressing = {
        peerIPv4 = "172.20.51.120";
        peerIPv6LinkLocal = "fe80::3618";
      };
    };
    jg-awsl = {
      remoteASN = 4242422188;
      latencyMs = 10;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22188;
        remoteAddress = "dn42-ams4.jg-awsl.xyz";
        remotePort = 22547;
        wireguardPubkey = "BfKaOkGCPy6PPb+mBday7iErZJEm5zZGx90Bq4VsTkM=";
      };
      addressing = {
        peerIPv4 = "172.23.231.110";
        peerIPv6LinkLocal = "fe80::2188";
      };
    };
    jlu5 = {
      remoteASN = 4242421080;
      latencyMs = 11;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21080;
        remoteAddress = "dn42-de-nbg01.jlu5.com";
        remotePort = 52547;
        wireguardPubkey = "oiSSSOMYxiiM0eQP9p8klwEfNn34hkNNv4S289WUciU=";
      };
      addressing = {
        peerIPv4 = "172.20.229.117";
        peerIPv6LinkLocal = "fe80::117";
      };
    };
    kaaass = {
      remoteASN = 4242421535;
      latencyMs = 31;
      tunnel = {
        type = "wireguard";
        localPort = 21535;
        remoteAddress = "fin.wd.kas.pub";
        remotePort = 22547;
        wireguardPubkey = "KO2mxfCYA3J28ot09QKXLhsNcHKVCdq4LkK6E04kInk=";
      };
      addressing = {
        peerIPv4 = "172.20.150.130";
        peerIPv6LinkLocal = "fe80::1535:2547";
      };
    };
    kskb = {
      remoteASN = 4242421817;
      latencyMs = 12;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21817;
        remoteAddress = "6.de.kskb.eu.org";
        remotePort = 22547;
        wireguardPubkey = "Sxn9qXnzu3gSBQFZ0vCh5t5blUJYgD+iHlCCG2hexg4=";
      };
      addressing = {
        peerIPv4 = "172.22.77.42";
        peerIPv6LinkLocal = "fe80::1817";
      };
    };
    kskb-uml = {
      remoteASN = 4201271111;
      latencyMs = 19;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 31111;
        wireguardPubkey = "9pNKpUdPSERqELcTCcvOLSeZsSSyw3kNFYmZ7epZZ0k=";
      };
      addressing = {
        peerIPv4 = "10.127.111.66";
        peerIPv6LinkLocal = "fe80::aa:1111:42";
      };
    };
    # liangjw = {
    #   remoteASN = 4242420604;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 20604;
    #     remoteAddress = "de1.dn42.cas7.moe";
    #     remotePort = 22547;
    #     wireguardPubkey = "KBKx5rWTFM0VfONOLiItlBDl5DmpzUprvb8ZnFHlvhk=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.23.89.3";
    #     peerIPv6LinkLocal = "fe80::604:3";
    #   };
    # };
    lutoma = {
      remoteASN = 64719;
      latencyMs = 5;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 64719;
        remoteAddress = "de-fra.dn42.lutoma.org";
        remotePort = 40012;
        wireguardPubkey = "xYpSTrk9SRwYzqo5cIUu4ywMBERi5RdO+M6aPKsx8zE=";
      };
      addressing = {
        peerIPv4 = "172.22.119.1";
        peerIPv6LinkLocal = "fe80::1312";
      };
    };
    # marcel = {
    #   remoteASN = 4242421555;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 21555;
    #     remoteAddress = "152.89.244.163";
    #     remotePort = 42547;
    #     wireguardPubkey = "tp/vNnNJVYDsgk2bHWBR7hyuc4gWGxdrldzei3+U9iU=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.20.233.34";
    #     peerIPv6LinkLocal = "fe80::1555";
    #   };
    # };
    matwolf = {
      remoteASN = 4242420688;
      latencyMs = 29;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20688;
        remoteAddress = "dn42-it01.wolf.network";
        remotePort = 52547;
        wireguardPubkey = "zQKdKiappowslCIbEyCiqLwrwUc6APcyEBIkIvzA6nw=";
      };
      addressing = {
        peerIPv4 = "172.20.28.224";
        peerIPv6 = "fda5:a8a8:9989:4242::1";
      };
    };
    mgot = {
      remoteASN = 4242420449;
      latencyMs = 15;
      tunnel = {
        type = "wireguard";
        localPort = 20449;
        remoteAddress = "161.97.157.50";
        remotePort = 45879;
        wireguardPubkey = "dftbPMcUAFmopjgUMx1zRHKO4hzwN40fMqf8TWe/1nE=";
      };
      addressing = {
        peerIPv4 = "172.23.99.249";
      };
    };
    myl = {
      remoteASN = 4242420245;
      latencyMs = 0;
      tunnel = {
        type = "wireguard";
        localPort = 20245;
        remoteAddress = "fran.s.myl7.org";
        remotePort = 22547;
        wireguardPubkey = "zwufU+ZTC/WRQWby73istrYE5WaFh0W3Yh9dPSwnpVY=";
      };
      addressing = {
        peerIPv4 = "172.22.107.2";
        peerIPv6LinkLocal = "fe80::245";
      };
    };
    n0emis = {
      remoteASN = 4242420197;
      latencyMs = 13;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20197;
        remoteAddress = "himalia.dn42.n0emis.eu";
        remotePort = 52547;
        wireguardPubkey = "ObF+xGC6DdddJer0IUw6nzC0RqzeKWwEiQU0ieowzhg=";
      };
      addressing = {
        peerIPv4 = "172.20.190.96";
        peerIPv6LinkLocal = "fe80::42:42:1";
      };
    };
    neochen = {
      remoteASN = 4201270000;
      latencyMs = 16;
      peering.network = "neo";
      tunnel = {
        type = "wireguard";
        localPort = 30000;
        remoteAddress = "caasih.neocloud.tw";
        remotePort = 54323;
        wireguardPubkey = "0cONH3BEJrFDnUs9WgcW9ghxNDjwwGEmDLbhgZ5Vnz4=";
      };
      addressing = {
        myIPv4 = "10.127.10.2";
        myIPv6 = "fd10:127:10:2::1";
        peerIPv4 = "10.127.2.16";
        peerIPv6 = "fd10:127:5f37:59df::2:16";
      };
    };
    nils = {
      remoteASN = 4242421592;
      latencyMs = 13;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21592;
        remoteAddress = "de01.dn42.trampel.org";
        remotePort = 42547;
        wireguardPubkey = "rYOgzxzXFPhOt5WTwKGZU5NW7FKZHind+isK6EihBhs=";
      };
      addressing = {
        peerIPv4 = "172.21.99.191";
        peerIPv6LinkLocal = "fe80::1592";
      };
    };
    noctis = {
      remoteASN = 4242422339;
      latencyMs = 12;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22339;
        remoteAddress = "amsonia.nodes.noctis.link";
        remotePort = 22547;
        wireguardPubkey = "DhGpUZuLtQnd3YXgBlIGXun8cRzrTWp3Bn3bHu0R5ys=";
      };
      addressing = {
        peerIPv4 = "172.23.37.2";
        peerIPv6LinkLocal = "fe80::2339:2";
      };
    };
    periloso = {
      remoteASN = 4242423770;
      latencyMs = 82;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23770;
        remoteAddress = "rbx1.dn42.servermade.com";
        remotePort = 52547;
        wireguardPubkey = "0ndXPAg17zmVx5CfxMblRfdcDjHRDB6OKBkYvvtq1g0=";
      };
      addressing = {
        peerIPv4 = "172.22.118.129";
        peerIPv6LinkLocal = "fe80::3770";
      };
    };
    sunnet = {
      remoteASN = 4242423088;
      latencyMs = 6;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23088;
        remoteAddress = "fra1-de.dn42.6700.cc";
        remotePort = 22547;
        wireguardPubkey = "TWQhJYK+ynNz7A4GMAQSHAyUUKTnAYrBfWTzzjzhAFs=";
      };
      addressing = {
        peerIPv4 = "172.21.100.195";
        peerIPv6LinkLocal = "fe80::3088:195";
      };
    };
    tchekda = {
      remoteASN = 4242421722;
      latencyMs = 9;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21722;
        remoteAddress = "peer.dn42.tchekda.fr";
        remotePort = 22547;
        wireguardPubkey = "OeOJ8kDei0m1jtQBGJb9IXaKzy8L1oTG+A4H+yFlHFo=";
      };
      addressing = {
        peerIPv4 = "172.20.4.97";
        peerIPv6LinkLocal = "fe80::1722:97";
      };
    };
    tech9 = {
      remoteASN = 4242421588;
      latencyMs = 5;
      tunnel = {
        type = "wireguard";
        localPort = 21588;
        remoteAddress = "de-fra02.dn42.tech9.io";
        remotePort = 50848;
        wireguardPubkey = "MD1EdVe9a0yycUdXCH3A61s3HhlDn17m5d07e4H33S0=";
      };
      addressing = {
        peerIPv4 = "172.20.16.141";
        myIPv6LinkLocal = "fe80::100";
        peerIPv6LinkLocal = "fe80::1588";
      };
    };
    uffsalot = {
      remoteASN = 4242420780;
      latencyMs = 6;
      tunnel = {
        type = "wireguard";
        localPort = 20780;
        remoteAddress = "router.fra4.dn42.brand-web.net";
        remotePort = 42547;
        wireguardPubkey = "7V65FxvD9AQetyUr0qSiu+ik8samB4Atrw2ekvC0xQM=";
      };
      addressing = {
        peerIPv4 = "172.20.191.129";
        peerIPv6LinkLocal = "fe80::780";
      };
    };
    x6c = {
      remoteASN = 4242420588;
      latencyMs = 13; # estimated, node is down atm
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20588;
        # DNS failure
        # remoteAddress = "fra.l.x6c.us";
        remotePort = 22547;
        wireguardPubkey = "tZ9TXziiPdFvEN+u7fICse0RnGmp6tI/zOB9uo0Fjik=";
      };
      addressing = {
        peerIPv4 = "172.23.110.73";
        peerIPv6LinkLocal = "fe80::73:1";
      };
    };
    yc = {
      remoteASN = 4242420904;
      latencyMs = 146;
      tunnel = {
        type = "wireguard";
        localPort = 20904;
        remoteAddress = "[2a0e:b107:270:9e00:216:3eff:fe24:247e]";
        remotePort = 22547;
        wireguardPubkey = "iiopXf9IezHWE4ieoH7KW8V0hpo1xqJNVYTv2cMnPHI=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::904";
      };
    };
    yura = {
      remoteASN = 4242422464;
      latencyMs = 0;
      badRouting = true;
      tunnel = {
        type = "wireguard";
        localPort = 22464;
        remoteAddress = "lon1.tunnel.dn42.moeternet.com";
        remotePort = 22547;
        wireguardPubkey = "nHehatsUU+MVVmxMcsD+jgKSNKDBDjjw+6+nDg1h0QI=";
      };
      addressing = {
        peerIPv4 = "172.20.191.193";
        peerIPv6LinkLocal = "fe80::2464";
      };
    };
  };
}
