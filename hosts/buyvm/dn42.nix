{ config, inputs, ... }:
{
  age.secrets.dn42-pingfinder-uuid.file =
    inputs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
  services."dn42-pingfinder".uuidFile = config.age.secrets.dn42-pingfinder-uuid.path;

  services.dn42 = {
    aldrich = {
      remoteASN = 4242420293;
      latencyMs = 8;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20293;
        remoteAddress = "nue2.dn42.wlms.dev";
        remotePort = 22547;
        wireguardPubkey = "rJ6XCxT/1Xk9WwSFlSoeJsz0cdXjro9EQzOrbNYhuUQ=";
      };
      addressing = {
        peerIPv4 = "172.20.209.129";
        peerIPv6LinkLocal = "fe80::293";
      };
    };
    androw = {
      remoteASN = 4242422575;
      latencyMs = 16;
      tunnel = {
        type = "wireguard";
        localPort = 22575;
        remoteAddress = "par2-fr.androw.eu";
        remotePort = 22547;
        wireguardPubkey = "P7L62FCA7wdH2mr6T3mif90Ms4cImhZjFiuHgqE6yig=";
      };
      addressing = {
        peerIPv4 = "172.23.186.33";
        peerIPv6LinkLocal = "fe80::2575";
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
    craig = {
      remoteASN = 4242420566;
      latencyMs = 13;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20566;
        remoteAddress = "dn15.de.surgebytes.com";
        remotePort = 32547;
        wireguardPubkey = "nTqfrHOPzYk9lH5/0i7RVDcdLjup0XPZ35uRy5sBzWg=";
      };
      addressing = {
        peerIPv4 = "172.21.99.15";
        peerIPv6LinkLocal = "fe80::566:15";
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
    huiliang = {
      remoteASN = 4242422928;
      latencyMs = 5;
      tunnel = {
        type = "wireguard";
        localPort = 22928;
        remoteAddress = "45.147.51.241";
        remotePort = 22547;
        wireguardPubkey = "oWIllu5l6T+uacm0e/ZvIM15qgQAcir7zTfyL9IE/24=";
      };
      addressing = {
        peerIPv4 = "172.22.78.99";
        peerIPv6LinkLocal = "fe80::2928";
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
    jasonxu = {
      remoteASN = 4242423658;
      latencyMs = 8;
      tunnel = {
        type = "wireguard";
        localPort = 23658;
        remoteAddress = "202.61.238.48";
        remotePort = 22547;
        wireguardPubkey = "7gbJe7eeFxHdZnHnlBA1H33HHLqnmGjgSWwsOLimtlM=";
      };
      addressing = {
        peerIPv4 = "172.20.193.3";
        peerIPv6 = "fd4e:d0:d38d::3";
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
    khoa = {
      remoteASN = 4242420868;
      latencyMs = 27;
      tunnel = {
        type = "wireguard";
        localPort = 20868;
        remoteAddress = "94.72.143.3";
        remotePort = 8682;
        wireguardPubkey = "gLqCSzX2Q5SBSDhwWbiaT2Xq1DVi/scz3/3RVuKDqCg=";
      };
      addressing = {
        peerIPv4 = "172.21.68.222";
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
    piotr = {
      remoteASN = 4242422033;
      latencyMs = 26;
      tunnel = {
        type = "gre";
        remoteAddress = "64.176.64.175";
      };
      addressing = {
        peerIPv4 = "172.20.194.4";
        peerIPv6 = "fde2:f42a:8ac9::4";
      };
    };
    potat0 = {
      remoteASN = 4242421816;
      latencyMs = 26;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21816;
        remoteAddress = "no1.dn42.potat0.cc";
        remotePort = 22547;
        wireguardPubkey = "H6HdsuQsav9puKyo8SJaML0vPU/a2lLQjTRc7dmiqjs=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::1816";
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
    sergey = {
      remoteASN = 4242420705;
      latencyMs = 54;
      tunnel = {
        type = "wireguard";
        localPort = 20705;
        remoteAddress = "151.250.94.244";
        remotePort = 716;
        wireguardPubkey = "9TNcbK3kEOPngUiUosc6iu4A0SE2z8MIUlnmpy8Pv1k=";
      };
      addressing = {
        peerIPv4 = "172.23.203.193";
      };
    };
    sernet = {
      remoteASN = 4242423947;
      latencyMs = 5;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23947;
        remoteAddress = "de-fra1.dn42.sherpherd.top";
        remotePort = 22547;
        wireguardPubkey = "KCd+kXNhe48hwOWng77V9E94PszQBqQvJW42c1P+6nk=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::3947:6";
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
    stevie-de = {
      remoteASN = 4242420337;
      latencyMs = 13;
      tunnel = {
        type = "wireguard";
        localPort = 20337;
        remoteAddress = "2a02:180:6:1::553";
        remotePort = 22547;
        wireguardPubkey = "mBNrNCAOvBWf0nukCNnNPW2N1pfyoBKZV0HFh7h2pBI=";
      };
      addressing = {
        peerIPv4 = "172.23.25.131";
        peerIPv6LinkLocal = "fe80::4337";
      };
    };
    stevie-it = {
      remoteASN = 4242420337;
      latencyMs = 20;
      tunnel = {
        type = "wireguard";
        localPort = 30337;
        remoteAddress = "2a02:29e0:1:1f1::1";
        remotePort = 22547;
        wireguardPubkey = "dJ8tHgXY12Fxrm+cCbaMsTpPZ/jPK8cGOyGwTT1Jxig=";
      };
      addressing = {
        peerIPv4 = "172.23.25.133";
        peerIPv6LinkLocal = "fe80::4337";
      };
    };
    stevie-nl = {
      remoteASN = 4242420337;
      latencyMs = 9;
      tunnel = {
        type = "wireguard";
        localPort = 40337;
        remoteAddress = "62.3.53.6";
        remotePort = 22547;
        wireguardPubkey = "QdALt/vMli/2loEYWnfO+BtDTL9IAUDcmKbv8sjQChI=";
      };
      addressing = {
        peerIPv4 = "172.23.25.141";
        peerIPv6LinkLocal = "fe80::4337";
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
    tobias = {
      remoteASN = 4242420577;
      latencyMs = 16;
      tunnel = {
        type = "wireguard";
        mtu = 1412;
        localPort = 20577;
        # Dynamic endpoint
        wireguardPubkey = "SPfVzZHC6U+8oAJ0rd0foq0PH9xRYKGRVHLosV1WbXc=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::577:1";
      };
    };
    ty3r0x = {
      remoteASN = 4242422596;
      latencyMs = 13;
      tunnel = {
        type = "wireguard";
        localPort = 22596;
        remoteAddress = "incognet.chaox.ro";
        remotePort = 22547;
        wireguardPubkey = "sxIWYIrbJKKnUjnQ/SIbcUlhYsBGZcAujnT9Xn5mdFw=";
      };
      addressing = {
        # peerIPv4 = "172.20.191.129";
        peerIPv6LinkLocal = "fe80::2596:5";
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
    yura = {
      remoteASN = 4242422464;
      latencyMs = 0;
      mode = "flapping";
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
