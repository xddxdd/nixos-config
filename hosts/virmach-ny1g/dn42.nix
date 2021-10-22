{ config, ... }:

{
  age.secrets.dn42-peering-virmach-ny1g-nelson.file = ../../secrets/dn42-peering/virmach-ny1g-nelson.age;

  services.dn42 = {
    baoshuo = {
      remoteASN = 4242420247;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20247;
        remoteAddress = "us1.dn42.as141776.net";
        remotePort = 22547;
        wireguardPubkey = "tRRiOqYhTsygV08ltrWtMkfJxCps1+HUyN4tb1J7Yn4=";
      };
      addressing = {
        peerIPv4 = "172.23.250.81";
        peerIPv6LinkLocal = "fe80::247";
      };
    };
    chuangzhu = {
      remoteASN = 4242423632;
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
    fixmix = {
      remoteASN = 4242421876;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21876;
        remoteAddress = "23.95.9.128";
        remotePort = 22547;
        wireguardPubkey = "EJvoVa5DrJl1rnryF4GThX1Rf86lMBtu2sg8Huru9Gs=";
      };
      addressing = {
        peerIPv4 = "172.22.66.53";
        peerIPv6LinkLocal = "fe80::1876";
      };
    };
    imlonghao = {
      remoteASN = 4242421888;
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
    nelson = {
      remoteASN = 4242423615;
      tunnel = {
        type = "openvpn";
        localPort = 23615;
        remoteAddress = "66.185.21.124";
        remotePort = 36152;
        openvpnStaticKeyPath = config.age.secrets.dn42-peering-virmach-ny1g-nelson.path;
      };
      addressing = {
        peerIPv4 = "172.20.39.120";
      };
    };
    oneacl = {
      remoteASN = 4242422633;
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
    perrin = {
      remoteASN = 4242423735;
      tunnel = {
        type = "wireguard";
        localPort = 23735;
        remoteAddress = "us1.dn42.cperrin.xyz";
        remotePort = 52547;
        wireguardPubkey = "p3v600DE0VBgZmBXZACi9ei9FdP+6An4SZge6CicH3E=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::3735:1";
      };
    };
    potat0 = {
      remoteASN = 4242421816;
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
    shiva = {
      remoteASN = 4242423073;
      tunnel = {
        type = "wireguard";
        localPort = 23073;
        remoteAddress = "dn42.shiva.eti.br";
        remotePort = 22547;
        wireguardPubkey = "ioFN575e/dD15BiD2mkXug6TKyeqYB4BC0f2NFMHYEM=";
      };
      addressing = {
        myIPv6Subnet = "fd22:ad17:8e8d:10::107";
        peerIPv6Subnet = "fd22:ad17:8e8d:10::106";
        IPv6SubnetMask = 127;
      };
    };
    sunnet = {
      remoteASN = 4242423088;
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
    tech9 = {
      remoteASN = 4242421588;
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
    x6c = {
      remoteASN = 4242420588;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20588;
        remoteAddress = "ewr.l.x6c.us";
        remotePort = 22547;
        wireguardPubkey = "kbkhBKH8NUo8uUaAPn5Poif0hAsOzBpB7+xdBKSTqi8=";
      };
      addressing = {
        peerIPv4 = "172.23.110.67";
        peerIPv6LinkLocal = "fe80::67:1";
      };
    };
  };
}
