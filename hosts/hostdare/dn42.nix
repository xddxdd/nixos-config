{ config, ... }:

{
  age.secrets.dn42-peering-hostdare-weiti.file = ../../secrets/dn42-peering/hostdare-weiti.age;

  services.dn42 = {
    anillc = {
      remoteASN = 4242422526;
      latencyMs = 8;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22526;
        remoteAddress = "las.awsl.ee";
        remotePort = 22547;
        wireguardPubkey = "NQfs6evQLemuJcdcvpO4ds1wXwUHTlzlQXWTJv+WCXY=";
      };
      addressing = {
        peerIPv4 = "172.22.167.97";
        peerIPv6LinkLocal = "fe80::2526";
      };
    };
    bin = {
      remoteASN = 4242422386;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 22386;
        remoteAddress = "us1.xiaoit.net";
        remotePort = 22547;
        wireguardPubkey = "1TJLXRtw6Lj/9w3V3A2+NaXMEmbuUdm2OiCBr6jnmgo=";
      };
      addressing = {
        peerIPv4 = "172.23.86.6";
        peerIPv6LinkLocal = "fe80::42:2386:86:6";
      };
    };
    burble = {
      remoteASN = 4242422601;
      latencyMs = 0;
      tunnel = {
        type = "wireguard";
        localPort = 22601;
        remoteAddress = "185.215.224.214";
        remotePort = 22547;
        wireguardPubkey = "hdU1wgobbpFzFgkH9YqX7XNRvU9Ajytm9SF8ESyhPxo=";
      };
      addressing = {
        peerIPv4 = "172.20.129.165";
        peerIPv6LinkLocal = "fe80::42:2601:3a:1";
      };
    };
    byron = {
      remoteASN = 4242423916;
      latencyMs = 27;
      tunnel = {
        type = "wireguard";
        localPort = 23916;
        remoteAddress = "108.61.195.177";
        remotePort = 22547;
        wireguardPubkey = "rx5Ov5fTJghtvhwK6JmFtUaOXNurm/XnbADgol9QMjk=";
      };
      addressing = {
        peerIPv4 = "172.20.132.133";
        myIPv6 = "fdbc:f9dc:67ad::dd:c85a:8a93";
        peerIPv6 = "fd6c:c6ed:38d5::dd:7cf:4e9";
      };
    };
    dgy = {
      remoteASN = 4242420826;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 20826;
        remoteAddress = "la.dn42.dgy.xyz";
        remotePort = 22547;
        wireguardPubkey = "IXjFALJFTr24HAhXKDsCnTRXmlc3kJHJiR4Nr44l5Uw=";
      };
      addressing = {
        peerIPv4 = "172.23.196.0";
        myIPv6LinkLocal = "fe80::1234";
        peerIPv6LinkLocal = "fe80::a0e:fb02";
      };
    };
    # dot = {
    #   remoteASN = 4242422137;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 22137;
    #     remoteAddress = "168.138.194.138";
    #     remotePort = 22547;
    #     wireguardPubkey = "F2o+5/s2cU9c+o5Ay8aj+25qX9STFS2fxGC4C6wNEmY=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.22.137.1";
    #     peerIPv6LinkLocal = "fe80::2137";
    #   };
    # };
    faker = {
      remoteASN = 4242423308;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23308;
        remoteAddress = "lax01.dn42.testnet.cyou";
        remotePort = 42547;
        wireguardPubkey = "fxzL3/spstTHn0cxaAlVZHIfa1VQP06FKjJL9P/Zzgg=";
      };
      addressing = {
        peerIPv4 = "172.23.99.65";
        peerIPv6LinkLocal = "fe80::3308:65";
      };
    };
    fixmix = {
      remoteASN = 4242421876;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21876;
        remoteAddress = "185.215.247.224";
        remotePort = 22547;
        wireguardPubkey = "haGUA0ZiXX0GKugLbwU3q4PL8KMBV+ktgwKxPr0xxkc=";
      };
      addressing = {
        peerIPv4 = "172.22.66.54";
        peerIPv6LinkLocal = "fe80::1876";
      };
    };
    gatuno = {
      remoteASN = 4242420180;
      latencyMs = 65;
      peering.mpbgp = true;
      tunnel = {
        type = "gre";
        remoteAddress = "187.189.193.102";
      };
      addressing = {
        peerIPv4 = "172.22.122.1";
        myIPv6Subnet = "fd42:470:f0ef:303::2";
        peerIPv6Subnet = "fd42:470:f0ef:303::1";
        IPv6SubnetMask = 64;
      };
    };
    iedon = {
      remoteASN = 4242422189;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 22189;
        remoteAddress = "204.44.99.106";
        remotePort = 22193;
        wireguardPubkey = "DIw4TKAQelurK10Sh1qE6IiDKTqL1yciI5ItwBgcHFA=";
      };
      addressing = {
        peerIPv4 = "172.23.91.114";
        myIPv6 = "fdbc:f9dc:67ad::dd:c85a:8a93";
        peerIPv6 = "fd42:4242:2189:ef::1";
      };
    };
    kioubit = {
      remoteASN = 4242423914;
      latencyMs = 71;
      tunnel = {
        type = "wireguard";
        localPort = 23914;
        remoteAddress = "us2.g-load.eu";
        remotePort = 22547;
        wireguardPubkey = "6Cylr9h1xFduAO+5nyXhFI1XJ0+Sw9jCpCDvcqErF1s=";
      };
      addressing = {
        peerIPv4 = "172.20.53.98";
        peerIPv6LinkLocal = "fe80::ade0";
      };
    };
    lazurite = {
      remoteASN = 4242422032;
      latencyMs = 8;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22032;
        remoteAddress = "nv1.us.lapinet27.com";
        remotePort = 22547;
        wireguardPubkey = "46Qxu55iYXC/GPydCXXm+OREH4/l3Pc1Sld5lpU+/Bc=";
      };
      addressing = {
        peerIPv4 = "172.22.180.65";
        peerIPv6LinkLocal = "fe80::2032";
      };
    };
    liki4 = {
      remoteASN = 4242420927;
      latencyMs = 8;
      peering.mpbgp = true;
      tunnel = {
        type = "gre";
        mtu = 1476;
        remoteAddress = "199.19.226.83";
      };
      addressing = {
        peerIPv4 = "172.21.77.33";
        peerIPv6 = "fd80:96c2:e41e:3dcc::1";
      };
    };
    lss233 = {
      remoteASN = 4242421826;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 21826;
        remoteAddress = "lax.n.lss233.com";
        remotePort = 52547;
        wireguardPubkey = "okfX4nra3vEz8TdXD08142TAi9YCYXOJAbF0DAx/dnw=";
      };
      addressing = {
        peerIPv4 = "172.20.143.50";
        peerIPv6LinkLocal = "fe80::1826";
      };
    };
    mo = {
      remoteASN = 4242421206;
      latencyMs = 167;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21206;
        remoteAddress = "107.155.18.38";
        remotePort = 22547;
        wireguardPubkey = "8j9Wo1G0IptLJv8QDeg+IXZewmBNqDZrXJYjrIlFkS4=";
      };
      addressing = {
        peerIPv4 = "172.23.104.160";
        peerIPv6LinkLocal = "fe80::1206";
      };
    };
    mayli = {
      remoteASN = 4242421123;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21123;
        remoteAddress = "dn42.ccp.ovh";
        remotePort = 22547;
        wireguardPubkey = "Z6OKJSR1sxMBgUd1uXEe/UxoBsOvRgbTnexy7z/ryUI=";
      };
      addressing = {
        peerIPv4 = "172.20.47.1";
        peerIPv6LinkLocal = "fe80::1123";
      };
    };
    miaotony = {
      remoteASN = 4242422688;
      latencyMs = 8;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        # A previous typo caused this inconsistency
        localPort = 22588;
        remoteAddress = "lv1.us.dn42.miaotony.xyz";
        remotePort = 22547;
        wireguardPubkey = "vfrrbtKAO5438daHrTD0SSS8V6yk78S/XW7DeFrYLXA=";
      };
      addressing = {
        peerIPv4 = "172.23.6.6";
        peerIPv6LinkLocal = "fe80::2688";
      };
    };
    # morc = {
    #   remoteASN = 4242422204;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 22204;
    #     remoteAddress = "108.61.220.214";
    #     remotePort = 22547;
    #     wireguardPubkey = "/1M4brKiLPpYkU8YZ4Leq2mLYHHSKCThQoIinPSjTjU=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.20.174.1";
    #     peerIPv6LinkLocal = "fe80::2204";
    #   };
    # };
    ncdwlq = {
      remoteASN = 4242423660;
      latencyMs = 8;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23660;
        remoteAddress = "us1.dn42.ncdwlq.space";
        remotePort = 22547;
        wireguardPubkey = "nWK3ZsUOksoz9/rKy6LwZmmQhYnM00sJFPOOMXrNh2s=";
      };
      addressing = {
        peerIPv4 = "172.21.86.32";
        peerIPv6LinkLocal = "fe80::3660";
      };
    };
    nicholas = {
      remoteASN = 4242421288;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21288;
        remoteAddress = "lax2.sc00.org";
        remotePort = 22547;
        wireguardPubkey = "PGTK1pzAYtSGoaPYfpEBCwm3S3gYAra3WkSMtshFfW8=";
      };
      addressing = {
        peerIPv4 = "172.20.233.131";
        peerIPv6LinkLocal = "fe80::1288";
      };
    };
    noctis = {
      remoteASN = 4242422339;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22339;
        remoteAddress = "laver.nodes.noctis.link";
        remotePort = 22547;
        wireguardPubkey = "n81DVZ/pE1lkKuzgb+FhGSgVxtGGhfTcq+DNb13PwBI=";
      };
      addressing = {
        peerIPv4 = "172.23.37.1";
        peerIPv6LinkLocal = "fe80::2339:1";
      };
    };
    nwn = {
      remoteASN = 4242420344;
      latencyMs = 1; # estimated, down atm
      tunnel = {
        type = "wireguard";
        localPort = 20344;
        # DNS failure, passive only
        # remoteAddress = "lax1.us.node.nwn.moe";
        remotePort = 22547;
        wireguardPubkey = "n81DVZ/pE1lkKuzgb+FhGSgVxtGGhfTcq+DNb13PwBI=";
      };
      addressing = {
        peerIPv4 = "172.23.110.97";
        peerIPv6LinkLocal = "fe80::cafe";
      };
    };
    oneacl = {
      remoteASN = 4242422633;
      latencyMs = 29;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22633;
        remoteAddress = "las.eastbnd.com";
        remotePort = 22547;
        wireguardPubkey = "XQpDtLZ0/OOQgIV829vPs1SYvxQk5TlUmrTAgI5S7xg=";
      };
      addressing = {
        peerIPv4 = "172.23.250.42";
        peerIPv6LinkLocal = "fe80::2633";
      };
    };
    # pomoke = {
    #   remoteASN = 4242422647;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 22647;
    #     remoteAddress = "149.28.75.71";
    #     remotePort = 60002;
    #     wireguardPubkey = "Y4V/SKNNqWMIIAOaBBbB/4u6NZX0xDZogh5SPuzEjxw=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.22.137.35";
    #     peerIPv6LinkLocal = "fe80::2e";
    #   };
    # };
    # styron = {
    #   remoteASN = 4242422553;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 22553;
    #     remoteAddress = "dn42.thekoziolfoundation.com";
    #     remotePort = 22547;
    #     wireguardPubkey = "7GoXgh22JZdQWUNEAmPEV0yxi/g1fqa1/Yvv/HlitCI=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.23.110.128";
    #     peerIPv6LinkLocal = "fe80::1:fdbc:f9dc:332";
    #   };
    # };
    sunnet = {
      remoteASN = 4242423088;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23088;
        remoteAddress = "lax1-us.dn42.6700.cc";
        remotePort = 22547;
        wireguardPubkey = "QSAeFPotqFpF6fFe3CMrMjrpS5AL54AxWY2w1+Ot2Bo=";
      };
      addressing = {
        peerIPv4 = "172.21.100.193";
        peerIPv6LinkLocal = "fe80::3088:193";
      };
    };
    # tech9 = {
    #   remoteASN = 4242421588;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 21588;
    #     remoteAddress = "us-dal01.dn42.tech9.io";
    #     remotePort = 59906;
    #     wireguardPubkey = "iEZ71NPZge6wHKb6q4o2cvCopZ7PBDqn/b3FO56+Hkc=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.20.16.140";
    #     myIPv6LinkLocal = "fe80::100";
    #     peerIPv6LinkLocal = "fe80::1588";
    #   };
    # };
    tsingyao = {
      remoteASN = 4242423699;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 23699;
        remoteAddress = "lax-us.tsingyao.pub";
        remotePort = 23699;
        wireguardPubkey = "O9Xl/1dU8hZXBZ7F5f9nAuG+JhrRakdf95NaXsktAmg=";
      };
      addressing = {
        peerIPv4 = "172.22.155.2";
        peerIPv6LinkLocal = "fe80::42:3699:2";
      };
    };
    tyler = {
      remoteASN = 4242420415;
      latencyMs = 1; # estimated, down atm
      tunnel = {
        type = "wireguard";
        localPort = 20415;
        remoteAddress = "dn42.r40.us";
        remotePort = 51823;
        wireguardPubkey = "O9Xl/1dU8hZXBZ7F5f9nAuG+JhrRakdf95NaXsktAmg=";
      };
      addressing = {
        peerIPv4 = "172.23.151.195";
      };
    };
    weiti = {
      remoteASN = 4242423905;
      latencyMs = 1;
      tunnel = {
        type = "openvpn";
        localPort = 22547;
        remoteAddress = "69.12.89.151";
        remotePort = 22547;
        openvpnStaticKeyPath = config.age.secrets.dn42-peering-hostdare-weiti.path;
      };
      addressing = {
        peerIPv4 = "172.20.175.196";
        peerIPv6LinkLocal = "fe80::42";
      };
    };
    # wsfnk = {
    #   # penalized for routing problem
    #   remoteASN = 4242420524;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 20524;
    #     remoteAddress = "144.34.157.43";
    #     remotePort = 22547;
    #     wireguardPubkey = "cbgn8rrQYZ6ZNVvG4IiHZiJZu4EohwJQr17iLb2Y1AA=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.20.58.193";
    #     peerIPv6LinkLocal = "fe80::f816:3eff:fe16:3c40";
    #   };
    # };
    x6c = {
      remoteASN = 4242420588;
      latencyMs = 1; # estimated, down atm
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20588;
        # DNS failure
        # remoteAddress = "fnc.l.x6c.us";
        remotePort = 22547;
        wireguardPubkey = "V4Cb9Jy5evG3XTUBrDWbneEE4IkP/hE8g35i4gQ53RM=";
      };
      addressing = {
        peerIPv4 = "172.23.110.68";
        peerIPv6LinkLocal = "fe80::68:1";
      };
    };
    yc = {
      remoteASN = 4242420904;
      latencyMs = 18;
      tunnel = {
        type = "wireguard";
        localPort = 20904;
        remoteAddress = "[2a0e:fd45:1000:167::2]";
        remotePort = 22547;
        wireguardPubkey = "EsxI5GO75zqC7E3vgxmaF1s93HHx+BI9dHeaNVKsa3o=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::904";
      };
    };
    # ykis = {
    #   remoteASN = 4242422021;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 22021;
    #     remoteAddress = "lax-node.ykis.moe";
    #     remotePort = 42547;
    #     wireguardPubkey = "lDPGJPvwoD5PdaDhL0NgNEb1evJKr+qHworHmrCzrEE=";
    #   };
    #   addressing = {
    #     peerIPv6LinkLocal = "fe80::2021";
    #   };
    # };
    yukari = {
      remoteASN = 4242421331;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21331;
        remoteAddress = "173.82.151.65";
        remotePort = 22547;
        wireguardPubkey = "+5/4lyROVefIgDfWN+Ou601rD+xgnJrBkqTTJiXrjUs=";
      };
      addressing = {
        peerIPv4 = "172.20.158.143";
        peerIPv6LinkLocal = "fe80::1331";
      };
    };
    # yuminli = {
    #   remoteASN = 4242422024;
    #   tunnel = {
    #     type = "wireguard";
    #     localPort = 22024;
    #     remoteAddress = "los-angeles-us.dn42.gcc.ac.cn";
    #     remotePort = 22547;
    #     wireguardPubkey = "2lsk+paO/QrRhz7KrnHm2xhWbOBtL/9pTiu5LN5V02A=";
    #   };
    #   addressing = {
    #     peerIPv4 = "172.22.124.1";
    #     peerIPv6LinkLocal = "fe80::1";
    #   };
    # };
    yura = {
      # penalized for routing problem
      remoteASN = 4242422464;
      latencyMs = 8;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22464;
        remoteAddress = "las.dneo.moeternet.com";
        remotePort = 22547;
        wireguardPubkey = "viR4CoaJTBHROo/Bgbb27hQ2ttr8AbByGY/yOz3D3GY=";
      };
      addressing = {
        peerIPv4 = "172.20.191.194";
        peerIPv6LinkLocal = "fe80::2464";
      };
    };
  };
}
