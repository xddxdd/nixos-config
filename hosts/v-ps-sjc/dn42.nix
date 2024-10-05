{ config, inputs, ... }:
{
  age.secrets.dn42-pingfinder-uuid.file =
    inputs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
  services."dn42-pingfinder".uuidFile = config.age.secrets.dn42-pingfinder-uuid.path;

  services.dn42 = {
    "5746xxxxx" = {
      remoteASN = 4242421566;
      latencyMs = 10;
      tunnel = {
        type = "wireguard";
        localPort = 21566;
        remoteAddress = "172.93.43.9";
        remotePort = 22547;
        wireguardPubkey = "XvMLP/vbrhDML0/1XAewaZK4ixtfbgtpqDYlncOEKiQ=";
      };
      addressing = {
        # myIPv4 = "172.20.171.170";
        peerIPv4 = "172.20.171.169";
      };
    };
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
    allen = {
      remoteASN = 4242421056;
      latencyMs = 9;
      tunnel = {
        type = "wireguard";
        localPort = 21056;
        remoteAddress = "74.48.162.139";
        remotePort = 22547;
        wireguardPubkey = "4ThSZjljTkbXQp/kB0z6TB1a+4fjV41VceVl3AhnzV8=";
      };
      addressing = {
        peerIPv4 = "172.21.89.225";
        peerIPv6LinkLocal = "fe80::1056";
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
    emerald = {
      remoteASN = 4242421151;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 21151;
        remoteAddress = "a.dn42.emeraldgames.top";
        remotePort = 22547;
        wireguardPubkey = "4caJOfpzFGdAyG7yVGXELTb/UTkm+Ey/G1tI41J5SBc=";
      };
      addressing = {
        peerIPv4 = "172.20.222.128";
        peerIPv6 = "fd44:429d:3900::";
      };
    };
    gatuno = {
      remoteASN = 4242420180;
      latencyMs = 65;
      tunnel = {
        type = "wireguard";
        localPort = 20180;
        remoteAddress = "ipv4.gatuno.mx";
        remotePort = 22547;
        wireguardPubkey = "qP/FHlk6XUur4EUo4zK5QBpdOGEtL/bHn0Ck8/hVfF4=";
      };
      addressing = {
        peerIPv4 = "172.22.122.1";
        myIPv6 = "fd42:470:f0ef:303::2";
        peerIPv6 = "fd42:470:f0ef:303::1";
        IPv6SubnetMask = 64;
      };
    };
    goforcex = {
      remoteASN = 4242421719;
      latencyMs = 11;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21719;
        remoteAddress = "us1.goforcex.top";
        remotePort = 22547;
        wireguardPubkey = "6DstUdlQmer+/xXEhuhnV4KYGqd/n6m2XxPGgk+RsBg=";
      };
      addressing = {
        peerIPv4 = "172.20.165.67";
        peerIPv6LinkLocal = "fe80::1719:67";
      };
    };
    jasonxu = {
      remoteASN = 4242423658;
      latencyMs = 8;
      tunnel = {
        type = "wireguard";
        localPort = 23658;
        remoteAddress = "74.48.219.8";
        remotePort = 22547;
        wireguardPubkey = "js2ZHPXaL5xscxQdqlD6qteqmsfKscPaBwP4XNL3QzI=";
      };
      addressing = {
        peerIPv4 = "172.20.193.1";
        peerIPv6 = "fd4e:d0:d38d::1";
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
    kemono = {
      remoteASN = 4242420358;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 20358;
        remoteAddress = "45.32.129.207";
        remotePort = 22547;
        wireguardPubkey = "ANZ9gLxxzJwIVM9NvFOJjiB4ilskScM071u8l9ULdz8=";
      };
      addressing = {
        peerIPv4 = "172.21.82.129";
        peerIPv6LinkLocal = "fe80::358";
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
      latencyMs = 10;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23914;
        remoteAddress = "us3.g-load.eu";
        remotePort = 22547;
        wireguardPubkey = "sLbzTRr2gfLFb24NPzDOpy8j09Y6zI+a7NkeVMdVSR8=";
      };
      addressing = {
        peerIPv4 = "172.20.53.103";
        peerIPv6LinkLocal = "fe80::ade0";
      };
    };
    kiyomi = {
      remoteASN = 4242421350;
      latencyMs = 20;
      tunnel = {
        type = "wireguard";
        localPort = 21350;
        remoteAddress = "sea.jvav.life";
        remotePort = 22547;
        wireguardPubkey = "k6RlAqY+CXvC7Kogys1U9solqYhFmXt+Ykzdmiat0W8=";
      };
      addressing = {
        peerIPv4 = "172.20.39.81";
        peerIPv6LinkLocal = "fe80::1350";
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
    li = {
      remoteASN = 4242420388;
      latencyMs = 19;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20388;
        remoteAddress = "23.167.8.110";
        remotePort = 22547;
        wireguardPubkey = "EHB+u2HnBY/8UGNehq+9oe7mW4+107SJywA7gbjxQE8=";
      };
      addressing = {
        peerIPv4 = "172.23.78.99";
        peerIPv6LinkLocal = "fe80::388";
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
    melvyn = {
      remoteASN = 4242423117;
      latencyMs = 10;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23117;
        remoteAddress = "dnsense.pub";
        remotePort = 22547;
        wireguardPubkey = "UVm6W75mp6R8yw+C9yICPW8F5j7tUzerh2Ecmqgt0B4=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::3117:2547";
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
    noreinx = {
      remoteASN = 4242421580;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21580;
        remoteAddress = "sfo.dn42.noreinx.me";
        remotePort = 22547;
        wireguardPubkey = "uUKad5JFD+Zfx/sApOcqJVrrsRS25en9ac6Tri/cZQk=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::1580:1";
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
    sernet = {
      remoteASN = 4242423947;
      latencyMs = 8;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23947;
        remoteAddress = "us-lax1.dn42.sherpherd.top";
        remotePort = 22547;
        wireguardPubkey = "2bQVZJjhIEaEelqwaQ+tbWDERbXjtXyidvYQL5COxyo=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::3947:4";
      };
    };
    stevensun = {
      remoteASN = 4242420602;
      latencyMs = 7;
      tunnel = {
        type = "wireguard";
        localPort = 20602;
        remoteAddress = "67.218.149.166";
        remotePort = 22547;
        wireguardPubkey = "vwiDVqB6WhKOqhqkXOso9lNqnhdL9accKg8BY+9ptHA=";
      };
      addressing = {
        peerIPv4 = "172.23.173.33";
        peerIPv6LinkLocal = "fe80::1212";
      };
    };
    stevie-lax = {
      remoteASN = 4242420337;
      latencyMs = 8;
      tunnel = {
        type = "wireguard";
        localPort = 20337;
        remoteAddress = "2602:f988:77:5:eabb:b4d9:3000:a950";
        remotePort = 22547;
        wireguardPubkey = "LI4yt68G9EbbcUVWhHOYQhZ4xAOz6OnmY5X4yXVQ2iA=";
      };
      addressing = {
        peerIPv4 = "172.23.25.135";
        peerIPv6LinkLocal = "fe80::4337";
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
    tristan = {
      remoteASN = 4242420585;
      latencyMs = 10;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20585;
        remoteAddress = "us1.dn42.atolm.net";
        remotePort = 22547;
        wireguardPubkey = "9MeUJU6gHl4lDLK+UJ/OZTp6dPGY8+jLkDDKqmSPWSM=";
      };
      addressing = {
        peerIPv4 = "172.23.183.3";
        peerIPv6LinkLocal = "fe80::585";
      };
    };
    yura = {
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
