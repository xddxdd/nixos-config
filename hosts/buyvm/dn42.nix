{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  age.secrets.dn42-pingfinder-uuid.file = inputs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
  services."dn42-pingfinder".uuidFile = config.age.secrets.dn42-pingfinder-uuid.path;

  services.dn42 = {
    androw = {
      remoteASN = 4242422575;
      latencyMs = 16;
      tunnel = {
        type = "wireguard";
        localPort = 22575;
        remoteAddress = "par3.fr.androw.eu";
        remotePort = 22547;
        wireguardPubkey = "P7L62FCA7wdH2mr6T3mif90Ms4cImhZjFiuHgqE6yig=";
      };
      addressing = {
        peerIPv4 = "172.23.186.33";
        peerIPv6LinkLocal = "fe80::2575";
      };
    };
    baiyu = {
      remoteASN = 4242421901;
      latencyMs = 5;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21901;
        remoteAddress = "node1.vultr.fra.europe.dn42.dalao-home.com";
        remotePort = 22547;
        wireguardPubkey = "Fq441bovZ0RAmgGPn+bbd2xLht9Mbsgw5YCa5bFgsm0=";
      };
      addressing = {
        peerIPv4 = "172.23.221.65";
        peerIPv6LinkLocal = "fe80::1901:2761:0:1";
      };
    };
    bastelfr = {
      remoteASN = 4242423668;
      latencyMs = 13;
      peering.mpbgp = true;
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
    bb-pgqm = {
      remoteASN = 4242420549;
      latencyMs = 6;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20549;
        remoteAddress = "lux.lux.dn42.bb-pgqm.com";
        remotePort = 22547;
        wireguardPubkey = "Yt27ZQW8ZTQDvK/PQ+cUw+sVaUJzWGGy1BKF5UzAJEs=";
      };
      addressing = {
        peerIPv4 = "172.20.56.6";
        peerIPv6LinkLocal = "fe80::549:4421:0:1";
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
    est-it = {
      remoteASN = 4242422206;
      latencyMs = 14;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22206;
        remoteAddress = "de1.dn42.est-it.de";
        remotePort = 13238;
        wireguardPubkey = "qgnbahUNQ5h4sp5+c8nAdWx64aebEZSOD9aS41tocBs=";
      };
      addressing = {
        peerIPv4 = "172.22.131.144";
        peerIPv6LinkLocal = "fe80::2206";
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
    kioubit = {
      remoteASN = 4242423914;
      latencyMs = 15;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23914;
        remoteAddress = "fr1.g-load.eu";
        remotePort = 22547;
        wireguardPubkey = "sLbzTRr2gfLFb24NPzDOpy8j09Y6zI+a7NkeVMdVSR8=";
      };
      addressing = {
        peerIPv4 = "172.20.53.102";
        peerIPv6LinkLocal = "fe80::ade0";
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
    marek = {
      remoteASN = 4242422923;
      latencyMs = 13;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22923;
        remoteAddress = "p2p-router.de";
        remotePort = 52547;
        wireguardPubkey = "hmR5tJCQEAse2FRNUctA8B/1B3brnNFMmVZGaO6CLQM=";
      };
      addressing = {
        peerIPv4 = "172.22.149.226";
        peerIPv6LinkLocal = "fe80::2924";
      };
    };
    matwolf = {
      remoteASN = 4242420688;
      latencyMs = 25;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20688;
        remoteAddress = "dn42-it-fe01.wolf.network";
        remotePort = 42547;
        wireguardPubkey = "pHGGXwEX3JBPt+Fs0hMHcnbHaGsd3hPk7EMAf+EJqj0=";
      };
      addressing = {
        peerIPv4 = "172.20.28.225";
        peerIPv6LinkLocal = "fe80::42:0688:42:2547";
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
    ricky = {
      remoteASN = 4242422458;
      latencyMs = 13;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22458;
        remoteAddress = "ipv4.nl-ams-a.nodes.pigeonhole.eu.org";
        remotePort = 22547;
        wireguardPubkey = "QJnmWUnPS9wKKkLHHuWBYMGAI20MH9OEo28O4qr5DV8=";
      };
      addressing = {
        peerIPv4 = "172.22.145.25";
        peerIPv6LinkLocal = "fe80::2458";
      };
    };
    spf = {
      remoteASN = 4242421964;
      latencyMs = 8;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21964;
        remoteAddress = "nl2.dn42.southparkfan.org";
        remotePort = 42547;
        wireguardPubkey = "GsmcrWbFTcje5e+hmc0D6qonrkTpHksGZuk0cLBjDmY=";
      };
      addressing = {
        peerIPv4 = "172.23.24.35";
        peerIPv6LinkLocal = "fe80::ade0";
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
    syc = {
      remoteASN = 4242420458;
      latencyMs = 10;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20458;
        remoteAddress = "eu-west1.dn42.huajitech.net";
        remotePort = 22547;
        wireguardPubkey = "J/EptroniSBNvzHhk0lQReRoHwV/m9vQo2l2CY69pXA=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::458";
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
        remoteAddress = "fra.l.x6c.us";
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
