{ config, inputs, ... }:
{
  age.secrets.dn42-pingfinder-uuid.file =
    inputs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
  services."dn42-pingfinder".uuidFile = config.age.secrets.dn42-pingfinder-uuid.path;

  age.secrets.dn42-virmach-ny1g-ceremon-openvpn.file =
    inputs.secrets + "/dn42/virmach-ny1g-ceremon-openvpn.age";

  services.dn42 = {
    exabyte = {
      remoteASN = 4242423340;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23340;
        remoteAddress = "dn42-us-nj01.exabyte.network";
        remotePort = 51849;
        wireguardPubkey = "fl5+PEZy8axmQxhAsvehIB8XeJmBMdy8vcTl4UR80n8=";
      };
      addressing = {
        peerIPv4 = "172.20.41.100";
        peerIPv6LinkLocal = "fe80::119";
      };
    };
    ceremon = {
      remoteASN = 4242420855;
      latencyMs = 66;
      tunnel = {
        type = "openvpn";
        localPort = 20855;
        remoteAddress = "107.172.108.90";
        remotePort = 22547;
        openvpnStaticKeyPath = config.age.secrets.dn42-virmach-ny1g-ceremon-openvpn.path;
      };
      addressing = {
        peerIPv4 = "172.23.93.35";
        peerIPv6LinkLocal = "fe80::855";
      };
    };
    craig = {
      remoteASN = 4242420566;
      latencyMs = 18;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20566;
        remoteAddress = "dn03.il.surgebytes.com";
        remotePort = 32547;
        wireguardPubkey = "doLcW+Vb67+6HCOInEuHjFr6nahrMRyQsBy6aPh+eGY=";
      };
      addressing = {
        peerIPv4 = "172.21.99.3";
        peerIPv6LinkLocal = "fe80::566:3";
      };
    };
    federico = {
      remoteASN = 4242420262;
      latencyMs = 18;
      tunnel = {
        type = "wireguard";
        localPort = 20262;
        remoteAddress = "v4.ash-1.fedemtz66.tech";
        remotePort = 22547;
        wireguardPubkey = "pxl/yYYDx52hr3tRB+e4rgYNzzZ+2NqRJvHljwdlcE4=";
      };
      addressing = {
        peerIPv4 = "192.168.202.62";
        peerIPv6LinkLocal = "fe80::1234";
      };
    };
    imlonghao = {
      remoteASN = 4242421888;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21888;
        remoteAddress = "us1.dn42.ni.sb";
        remotePort = 22547;
        wireguardPubkey = "uVIBY5keaBLtkT7oyD/W/TgEBiXerr/IPxtH+JO0amI=";
      };
      addressing = {
        peerIPv4 = "172.22.68.0";
        peerIPv6LinkLocal = "fe80::1888";
      };
    };
    jlu5 = {
      remoteASN = 4242421080;
      latencyMs = 18;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21080;
        remoteAddress = "dn42-us-nyc01.jlu5.com";
        remotePort = 52547;
        wireguardPubkey = "YrlNsVP9bbTqNuNyQ/MVFzulZKNW5vMaDMzHVFNXSSE=";
      };
      addressing = {
        peerIPv4 = "172.20.229.123";
        peerIPv6LinkLocal = "fe80::123";
      };
    };
    kemono = {
      remoteASN = 4242420358;
      latencyMs = 89;
      tunnel = {
        type = "wireguard";
        localPort = 20358;
        remoteAddress = "45.32.129.207";
        remotePort = 22548;
        wireguardPubkey = "ANZ9gLxxzJwIVM9NvFOJjiB4ilskScM071u8l9ULdz8=";
      };
      addressing = {
        peerIPv4 = "172.21.82.129";
        peerIPv6LinkLocal = "fe80::358";
      };
    };
    kioubit = {
      remoteASN = 4242423914;
      latencyMs = 1;
      peering.mpbgp = true;
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
    kskb-uml = {
      remoteASN = 4201271111;
      latencyMs = 29;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 31111;
        wireguardPubkey = "2FSX+6N/PwfipN/jXMj++4mabFQj25MXDy51mnnz3AA=";
      };
      addressing = {
        peerIPv4 = "10.127.111.51";
        peerIPv6LinkLocal = "fe80::aa:1111:33";
      };
    };
    lukas = {
      remoteASN = 4242423372;
      latencyMs = 46;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23372;
        remoteAddress = "yxe.beckerit.cc";
        remotePort = 22547;
        wireguardPubkey = "okxcWYCduqtZfKfZVTLc4cCMxOXBYvUEkl8OLzxe3hQ=";
      };
      addressing = {
        peerIPv4 = "172.23.180.193";
        peerIPv6LinkLocal = "fe80::3372";
      };
    };
    lutoma = {
      remoteASN = 64719;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 64719;
        remoteAddress = "us-nyc.dn42.lutoma.org";
        remotePort = 40003;
        wireguardPubkey = "F+vuNKwb8wbDiZsdHgZnYUG8y3YxnLB8Hm/KpwC7w2w=";
      };
      addressing = {
        peerIPv4 = "172.22.119.10";
        peerIPv6LinkLocal = "fe80::1312";
      };
    };
    oneacl = {
      remoteASN = 4242422633;
      latencyMs = 10;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22633;
        remoteAddress = "lga.eastbnd.com";
        remotePort = 22547;
        wireguardPubkey = "ifJ451maK3eaEg1FrewNbgCEMjMmEinYt1Sd1pwGTDc=";
      };
      addressing = {
        peerIPv4 = "172.23.250.42";
        peerIPv6LinkLocal = "fe80::2633";
      };
    };
    pebkac = {
      remoteASN = 4242422092;
      latencyMs = 18;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22092;
        remoteAddress = "us0.dn42.pebkac.gr";
        remotePort = 52547;
        wireguardPubkey = "NnIsCmxiGctp5hR9ViuNRjZXr8lxtjn382sIwsV+GBU=";
      };
      addressing = {
        peerIPv4 = "172.21.67.200";
        peerIPv6LinkLocal = "fe80::42:2547:1";
      };
    };
    ricky = {
      remoteASN = 4242422458;
      latencyMs = 40;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22458;
        remoteAddress = "natv4.us-mci-a.nodes.pigeonhole.eu.org";
        remotePort = 42547;
        wireguardPubkey = "XjX37H3ZYd9QuGu+M1Ut6RLlDu3J+8ib3grbanlp0Vs=";
      };
      addressing = {
        peerIPv4 = "172.22.145.9";
        peerIPv6LinkLocal = "fe80::2458";
      };
    };
    sernet = {
      remoteASN = 4242423947;
      latencyMs = 3;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23947;
        remoteAddress = "us-nyc1.dn42.sherpherd.top";
        remotePort = 22547;
        wireguardPubkey = "PXkGrHooCFnB6N8bD6isgVjhl9GvzD2CLqlA+e2XikM=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::3947:7";
      };
    };
    slirya = {
      remoteASN = 4242422608;
      latencyMs = 130;
      tunnel = {
        type = "wireguard";
        localPort = 22608;
        remoteAddress = "64.181.170.30";
        remotePort = 22547;
        wireguardPubkey = "Stu420ttmPnHE3agY2aOExrvN8uj2bPgd26ypsKdlk0=";
      };
      addressing = {
        peerIPv4 = "172.21.105.1";
        peerIPv6LinkLocal = "fe80::2608";
      };
    };
    sunnet = {
      remoteASN = 4242423088;
      latencyMs = 15;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23088;
        remoteAddress = "buff1-us.dn42.6700.cc";
        remotePort = 22547;
        wireguardPubkey = "wAI2D+0GeBnFUqm3xZsfvVlfGQ5iDWI/BykEBbkc62c=";
      };
      addressing = {
        peerIPv4 = "172.21.100.194";
        peerIPv6LinkLocal = "fe80::3088:1";
      };
    };
    syc = {
      remoteASN = 4242420458;
      latencyMs = 11;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20458;
        remoteAddress = "us-east1.dn42.huajitech.net";
        remotePort = 22547;
        wireguardPubkey = "jk6jHDQlnMelT7hllXZ4djmXTR2an1xUtuZsJazSzzA=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::458";
      };
    };
    tech9 = {
      remoteASN = 4242421588;
      latencyMs = 14;
      tunnel = {
        type = "wireguard";
        localPort = 21588;
        remoteAddress = "us-chi01.dn42.tech9.io";
        remotePort = 54462;
        wireguardPubkey = "0kb8ffMcbx8oXZ3Ii5khOuCzmRqM2Cy0IslmrWtRGSk=";
      };
      addressing = {
        peerIPv4 = "172.20.16.139";
        myIPv6LinkLocal = "fe80::100";
        peerIPv6LinkLocal = "fe80::1588";
      };
    };
    ty3r0x = {
      remoteASN = 4242422596;
      latencyMs = 18;
      tunnel = {
        type = "wireguard";
        localPort = 22596;
        remoteAddress = "racknerd.chaox.ro";
        remotePort = 22547;
        wireguardPubkey = "rZYo5BZ4D8Y5VSwCoAI+qDvtBM+HuRtG6YVvR0cZ3gs=";
      };
      addressing = {
        # peerIPv4 = "172.20.191.129";
        peerIPv6LinkLocal = "fe80::2596:7";
      };
    };
    xkww3n = {
      remoteASN = 4242421513;
      latencyMs = 18;
      tunnel = {
        type = "wireguard";
        localPort = 21513;
        remoteAddress = "198.98.62.121";
        remotePort = 22547;
        wireguardPubkey = "PjS6RoBo4vcTPzQqpLeFkhkcvKSKJz6MeZfeGgGuYW8=";
      };
      addressing = {
        peerIPv4 = "172.21.101.113";
        peerIPv6LinkLocal = "fe80::1113";
      };
    };
    yinfeng = {
      remoteASN = 4242420128;
      latencyMs = 9;
      tunnel = {
        type = "wireguard";
        localPort = 20128;
        remoteAddress = "207.90.192.101";
        remotePort = 22547;
        wireguardPubkey = "G3/9l3sOzgcoBhxdqn8WH5aBAulsNgmCzN2b9N5gwXw=";
      };
      addressing = {
        peerIPv4 = "172.23.224.99";
        peerIPv6LinkLocal = "fe80::128";
      };
    };
    yuheng = {
      remoteASN = 4242422324;
      latencyMs = 54;
      tunnel = {
        type = "wireguard";
        localPort = 22324;
        remoteAddress = "usa-ap-01.usa.d.pool.yuheng.hl.cn";
        remotePort = 22547;
        wireguardPubkey = "aTrHO4Pm1p1FITTx7noaiW3VXLGjRv8MVoZ6w8MxX1g=";
      };
      addressing = {
        peerIPv4 = "172.23.126.225";
        peerIPv6LinkLocal = "fe80::2324";
      };
    };
    zdong = {
      remoteASN = 4242422354;
      latencyMs = 5;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22354;
        remoteAddress = "dn42.zdong.me";
        remotePort = 22547;
        wireguardPubkey = "Uvd/M5SOpWxyowTIbEU0KUz+KOEJAcTSX0ddO0tCQRg=";
      };
      addressing = {
        peerIPv4 = "172.23.132.129";
        peerIPv6LinkLocal = "fe80::2354";
      };
    };
  };
}
