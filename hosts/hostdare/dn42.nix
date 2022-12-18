{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  age.secrets.dn42-pingfinder-uuid.file = inputs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
  services."dn42-pingfinder".uuidFile = config.age.secrets.dn42-pingfinder-uuid.path;

  services.dn42 = {
    akira = {
      remoteASN = 4242422375;
      latencyMs = 11;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22375;
        remoteAddress = "us1.4k1ra.ml";
        remotePort = 22547;
        wireguardPubkey = "VUUIB+ji/0sH4wmFwYDHL6yUsgXvy9NysKOM8RQ9qGs=";
      };
      addressing = {
        peerIPv4 = "172.23.75.2";
        peerIPv6LinkLocal = "fe80::2375";
      };
    };
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
    baiyu = {
      remoteASN = 4242421901;
      latencyMs = 11;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21901;
        remoteAddress = "node1.vultr.sjc.america.dn42.dalao-home.com";
        remotePort = 22547;
        wireguardPubkey = "Kt0c0mpmA4gtRUePxC0tkKrkAZZgrulTYgC5EL/s1Hs=";
      };
      addressing = {
        peerIPv4 = "172.23.221.68";
        peerIPv6LinkLocal = "fe80::1901:8401:1:1";
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
    faker = {
      remoteASN = 4242423308;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23308;
        # remoteAddress = "lax01.dn42.testnet.cyou";
        remotePort = 42547;
        wireguardPubkey = "fxzL3/spstTHn0cxaAlVZHIfa1VQP06FKjJL9P/Zzgg=";
      };
      addressing = {
        peerIPv4 = "172.23.99.65";
        peerIPv6LinkLocal = "fe80::3308:65";
      };
    };
    ffee = {
      remoteASN = 4242423397;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23397;
        # remoteAddress = "dn42-la-us-1.ffeeco.coffee";
        remotePort = 22547;
        wireguardPubkey = "ee6gKhvQDngc8rIR1IhHz1ng2M7UHzIY598TICJUPm0=";
      };
      addressing = {
        peerIPv4 = "172.22.162.133";
        peerIPv6LinkLocal = "fe80::858:d3ff:fe7e:f91b";
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
        remoteAddress = "186.96.168.147";
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
    jlu5 = {
      remoteASN = 4242421080;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21080;
        remoteAddress = "dn42-de-nbg01.jlu5.com";
        remotePort = 22547;
        wireguardPubkey = "H5XoB+8N4LoMAW4+vJ2jD6fO5vqQGZdj4MSip5clcCg=";
      };
      addressing = {
        peerIPv4 = "172.20.229.122";
        peerIPv6LinkLocal = "fe80::122";
      };
    };
    keuin = {
      remoteASN = 4242421966;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21966;
        remoteAddress = "server1.connect.keuin.cc";
        remotePort = 22547;
        wireguardPubkey = "jW4UOzA/9ggGzk0PkqW563SzE5pn5X8DvZz/+hD+mRo=";
      };
      addressing = {
        peerIPv4 = "172.23.36.65";
        peerIPv6LinkLocal = "fe80::1966";
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
    kskb = {
      remoteASN = 4242421817;
      latencyMs = 10;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21817;
        remoteAddress = "4.us.kskb.eu.org";
        remotePort = 22547;
        wireguardPubkey = "dZzVdXbQPnWPpHk8QfW/p+MfGzAkMBuWpxEIXzQCggY=";
      };
      addressing = {
        peerIPv4 = "172.22.77.40";
        peerIPv6LinkLocal = "fe80::1817";
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
    lutoma = {
      remoteASN = 64719;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 64719;
        remoteAddress = "us-lax.dn42.lutoma.org";
        remotePort = 40006;
        wireguardPubkey = "7ZolMnp0snzbOaZ6AkyXTi/s3GHFHfzevlJaHhP/umQ=";
      };
      addressing = {
        peerIPv4 = "172.22.119.11";
        peerIPv6LinkLocal = "fe80::1312";
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
    moe233 = {
      remoteASN = 4242420253;
      latencyMs = 12;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20253;
        remoteAddress = "sfo1.dn42.moe233.net";
        remotePort = 22547;
        wireguardPubkey = "C3SneO68SmagisYQ3wi5tYI2R9g5xedKkB56Y7rtPUo=";
      };
      addressing = {
        peerIPv4 = "172.23.69.161";
        peerIPv6LinkLocal = "fe80::253";
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
    ricky = {
      remoteASN = 4242422458;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22458;
        remoteAddress = "natv4.us-lax-a.nodes.pigeonhole.eu.org";
        remotePort = 20145;
        wireguardPubkey = "usSOnTQKWozKiB3CM65TY3hv64dxQLnIx9ywc0J9awY=";
      };
      addressing = {
        peerIPv4 = "172.22.145.8";
        peerIPv6LinkLocal = "fe80::2458";
      };
    };
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
    syc = {
      remoteASN = 4242420458;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20458;
        remoteAddress = "us-west1.dn42.huajitech.net";
        remotePort = 22547;
        wireguardPubkey = "Y13v0Xzf6zJQGtL2qJSwVyLNSxipYoGpq4y/5aU7omg=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::458";
      };
    };
    tivipax = {
      remoteASN = 4242422778;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 22778;
        # remoteAddress = "v4.lax1.tivipax.tk";
        remotePort = 22547;
        wireguardPubkey = "cPtZSwHTMrzsIv88mnnkMHyjItsRQqHJqdGQ/+ix9Bs=";
      };
      addressing = {
        peerIPv4 = "172.20.42.137";
        peerIPv6LinkLocal = "fe80::2778";
      };
    };
    tristan = {
      remoteASN = 4242420585;
      latencyMs = 10;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20585;
        # Peer cannot accept incoming connections
        # remoteAddress = "us1.dn42.atolm.net";
        remotePort = 22547;
        wireguardPubkey = "9MeUJU6gHl4lDLK+UJ/OZTp6dPGY8+jLkDDKqmSPWSM=";
      };
      addressing = {
        peerIPv4 = "172.23.183.3";
        peerIPv6LinkLocal = "fe80::585";
      };
    };
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
    yura = {
      remoteASN = 4242422464;
      latencyMs = 8;
      badRouting = true;
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
    yuzu = {
      remoteASN = 4242421131;
      latencyMs = 9;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21131;
        remoteAddress = "ipv4.phoenix.us.dn42.yuzu.im";
        remotePort = 22547;
        wireguardPubkey = "abDdEXgpaUNfEVPYLv1GTA+1TjkRbk5MNUi0fczYflw=";
      };
      addressing = {
        peerIPv4 = "172.21.109.34";
        peerIPv6LinkLocal = "fe80::1131";
      };
    };
  };
}
