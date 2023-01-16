{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  age.secrets.dn42-pingfinder-uuid.file = inputs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
  services."dn42-pingfinder".uuidFile = config.age.secrets.dn42-pingfinder-uuid.path;

  services.dn42 = {
    bri = {
      remoteASN = 4242422825;
      latencyMs = 5;
      # peering.mpbgp = true;
      tunnel = {
        type = "zerotier";
      };
      addressing = {
        myIPv4 = "172.23.217.90";
        peerIPv4 = "172.23.217.65";
        IPv4SubnetMask = 27;
        myIPv6 = "fde4:da74:55b2:3a9b:4999:939e:a04:1298";
        peerIPv6 = "fde4:da74:55b2:3a9b:4999:93ef:7d96:e6be";
        IPv6SubnetMask = 80;
      };
    };
    chuangzhu = {
      remoteASN = 4242423632;
      latencyMs = 35;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23632;
        remoteAddress = "chokeberry.link.melty.land";
        remotePort = 42547;
        wireguardPubkey = "oCgzClTd8nECzDqS20/dKaitAHUN1TgIIeVZKAsJ1FA=";
      };
      addressing = {
        peerIPv4 = "172.23.36.35";
        peerIPv6LinkLocal = "fe80::3632";
      };
    };
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
    ifreetion = {
      remoteASN = 4242421255;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21255;
        remoteAddress = "dn42-us-nyc1.acgcl.net";
        remotePort = 32547;
        wireguardPubkey = "nPj3l9HhMVoWgjBPCGIzTvrDO5ogcEWm8IkycQWz/jA=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::10a0";
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
    kclg = {
      remoteASN = 4242421877;
      latencyMs = 11;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21877;
        remoteAddress = "lilie.lilynet.work";
        remotePort = 22547;
        wireguardPubkey = "jYwRBFYATL1spAlXKGI4rkY/27s9ufiD98ctzvP/1GI=";
      };
      addressing = {
        peerIPv4 = "172.23.180.1";
        peerIPv6LinkLocal = "fe80::1d89";
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
    potat0 = {
      remoteASN = 4242421816;
      latencyMs = 17;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21816;
        remoteAddress = "peer.us1.dn42.potat0.cc";
        remotePort = 22547;
        wireguardPubkey = "LUwqKS6QrCPv510Pwt1eAIiHACYDsbMjrkrbGTJfviU=";
      };
      addressing = {
        peerIPv4 = "172.23.246.1";
        peerIPv6LinkLocal = "fe80::1816";
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
    weilence = {
      remoteASN = 4242423739;
      latencyMs = 67;
      tunnel = {
        type = "wireguard";
        localPort = 23739;
        remoteAddress = "107.173.153.239";
        remotePort = 22547;
        wireguardPubkey = "h+WR54NcjUQ0f7dsxxexqcD0VuKEefCBqW85c3WuGx0=";
      };
      addressing = {
        peerIPv4 = "172.20.225.1";
        peerIPv6 = "fd33:c25e:9d77::1";
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
    ytc233 = {
      remoteASN = 4242423054;
      latencyMs = 62;
      tunnel = {
        type = "wireguard";
        localPort = 23054;
        remoteAddress = "lv.moeclub.top";
        remotePort = 22547;
        wireguardPubkey = "DVt4r1oluoeX+nwevQ5FldlHQ4l3JVj1lfyHEQGUBm8=";
      };
      addressing = {
        peerIPv4 = "172.23.246.65";
        peerIPv6LinkLocal = "fe80::3054";
      };
    };
  };
}
