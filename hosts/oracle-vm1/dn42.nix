{ config, inputs, ... }:
{
  age.secrets.dn42-pingfinder-uuid.file =
    inputs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
  services."dn42-pingfinder".uuidFile = config.age.secrets.dn42-pingfinder-uuid.path;

  services.dn42 = {
    atolm = {
      remoteASN = 4242420585;
      latencyMs = 3;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20585;
        remoteAddress = "jp1.dn42.atolm.net";
        remotePort = 22547;
        wireguardPubkey = "nO4iuPSTPDVyq16TGlIanQatEtdYiY0WsSF2yS4Dbxo=";
      };
      addressing = {
        # peerIPv4 = "172.20.56.4";
        peerIPv6LinkLocal = "fe80::585";
      };
    };
    baka = {
      remoteASN = 4242423374;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23374;
        remoteAddress = "jp01.dn42.baka.pub";
        remotePort = 22547;
        wireguardPubkey = "N7iQzqWLPb6lpRlf7grQG6rEzQOvDZWkmsRDkRnniH0=";
      };
      addressing = {
        peerIPv4 = "172.20.154.226";
        peerIPv6LinkLocal = "fe80::2999:226";
      };
    };
    bb-pgqm = {
      remoteASN = 4242420549;
      latencyMs = 3;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20549;
        remoteAddress = "tyo.jpn.dn42.bb-pgqm.com";
        remotePort = 22547;
        wireguardPubkey = "9wF7vXyJ+uBUb3At/SODOkaBSEQSdvpdtCwRL9kiuFc=";
      };
      addressing = {
        peerIPv4 = "172.20.56.4";
        peerIPv6LinkLocal = "fe80::549:3921:0:1";
      };
    };
    craig = {
      remoteASN = 4242420566;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20566;
        remoteAddress = "dn19.tyo.surgebytes.com";
        remotePort = 32547;
        wireguardPubkey = "KFvOAxzHJkpQkO16ZzxWp3Hp/rSs+0ZWwty61CvkQlw=";
      };
      addressing = {
        peerIPv4 = "172.21.99.19";
        peerIPv6LinkLocal = "fe80::566:19";
      };
    };
    ifreetion = {
      remoteASN = 4242421255;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21255;
        remoteAddress = "dn42-jp-nrt2.acgcl.net";
        remotePort = 32547;
        wireguardPubkey = "iRtfmmbhLn59caa8z9HTa4ZHG9L0xYWcrKmAs/ehGmo=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::1060";
      };
    };
    jlu5 = {
      remoteASN = 4242421080;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21080;
        remoteAddress = "tyo.peer.highdef.network";
        remotePort = 22547;
        wireguardPubkey = "iJXjwJGGrUTQy/P3OXmZ5lM4cjrDAd9K+vonZVUZjxY=";
      };
      addressing = {
        peerIPv4 = "172.20.229.124";
        peerIPv6LinkLocal = "fe80::124";
      };
    };
    k1t3ab = {
      remoteASN = 4242421591;
      latencyMs = 79;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21591;
        remoteAddress = "az.kiteab.me";
        remotePort = 22547;
        wireguardPubkey = "eG9V/YHHvzK+1Hv1WoWHaZeRHCrs53rMuR7BoGwvq3A=";
      };
      addressing = {
        peerIPv4 = "172.23.69.192";
        peerIPv6LinkLocal = "fe80::1591";
      };
    };
    kskb = {
      remoteASN = 4242421817;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21817;
        remoteAddress = "jp.kskb.eu.org";
        remotePort = 22547;
        wireguardPubkey = "LDtwAj4hsCOmZEnAcb2uzOH5FP1q43ploOoG/8tDeC4=";
      };
      addressing = {
        peerIPv4 = "172.22.77.47";
        peerIPv6LinkLocal = "fe80::1817";
      };
    };
    lze = {
      remoteASN = 4242422171;
      latencyMs = 2;
      tunnel = {
        type = "wireguard";
        localPort = 22171;
        remoteAddress = "frp-fly.top";
        remotePort = 12709;
        wireguardPubkey = "2J/ua7wrsui5ZHf7OFMCSAcxXDHpc3h5FFVNUopeRH4=";
      };
      addressing = {
        peerIPv4 = "172.20.154.161";
        peerIPv6LinkLocal = "fe80::2171";
      };
    };
    merlyn = {
      remoteASN = 4242422380;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 22380;
        remoteAddress = "tokyo.merlyn.eu.org";
        remotePort = 22547;
        wireguardPubkey = "iHBahOdFjLlSPhd12L+cp5wgIT/+eWl0mjnahi8yNQ0=";
      };
      addressing = {
        peerIPv4 = "172.22.125.254";
        peerIPv6LinkLocal = "fe80::5400:4ff:fe1e:b4e9";
      };
    };
    moo = {
      remoteASN = 4242423999;
      latencyMs = 1;
      tunnel = {
        type = "wireguard";
        localPort = 23999;
        remoteAddress = "138.3.209.153";
        remotePort = 32547;
        wireguardPubkey = "mMGGxtEqsagrx1Raw57C2H3Stl6ch/cUuF7y08eVgBE=";
      };
      addressing = {
        peerIPv4 = "172.22.144.65";
        peerIPv6 = "fd36:62be:ef51:1::1";
      };
    };
    qyn1230 = {
      remoteASN = 4242422463;
      latencyMs = 10;
      tunnel = {
        type = "wireguard";
        localPort = 22463;
        remoteAddress = "43.201.146.222";
        remotePort = 22547;
        wireguardPubkey = "SshoxktVNRBmC+t584vsboweIDTCW29I+ym6TfWv5nk=";
      };
      addressing = {
        peerIPv4 = "172.21.82.41";
        peerIPv6LinkLocal = "fe80::a3:b6ff:fef1:e566";
      };
    };
    ricky = {
      remoteASN = 4242422458;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22458;
        remoteAddress = "jp-tyo-a.nodes.pigeonhole.eu.org";
        remotePort = 22547;
        wireguardPubkey = "OEjDZMJF1USPznWEf2UbbdHexNAlP1/EKkKTN95Nx0Q=";
      };
      addressing = {
        peerIPv4 = "172.22.145.19";
        peerIPv6LinkLocal = "fe80::2458";
      };
    };
    syc = {
      remoteASN = 4242420458;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 20458;
        remoteAddress = "jp1.dn42.huajitech.net";
        remotePort = 22547;
        wireguardPubkey = "lLcWnM8vTogYe4H96zSeKmtz8MBL+g0ajnMcFDsYIk8=";
      };
      addressing = {
        peerIPv6LinkLocal = "fe80::458";
      };
    };
    uuuun = {
      remoteASN = 4242421886;
      latencyMs = 33;
      # peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21886;
        remoteAddress = "d1.000666.xyz";
        remotePort = 22547;
        wireguardPubkey = "drzVP686qPxb/WmyPo+joJCiHXI5lyW/NEF5N206MXc=";
      };
      addressing = {
        peerIPv4 = "172.21.113.129";
        peerIPv6LinkLocal = "fe80::33";
      };
    };
    wenlong = {
      remoteASN = 4242422366;
      latencyMs = 2;
      # peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22366;
        remoteAddress = "149.62.44.85";
        remotePort = 22547;
        wireguardPubkey = "hPe0oxxBMOJOqbCfjTdg8nHIrrx4hslqNaHKjwDMygw=";
      };
      addressing = {
        peerIPv4 = "172.22.109.161";
        peerIPv6LinkLocal = "fe80::1423:1";
      };
    };
    wq = {
      remoteASN = 4242422830;
      latencyMs = 8;
      tunnel = {
        type = "wireguard";
        localPort = 22830;
        remoteAddress = "tyo1.madless.club";
        remotePort = 22547;
        wireguardPubkey = "IMSdAJ8NjjW89fiFRu4mkgTsmAukjPfy/sI3UmMBzV4=";
      };
      addressing = {
        peerIPv4 = "172.20.236.129";
        peerIPv6LinkLocal = "fe80::17ff:fe00:a5e7";
      };
    };
    xlyf = {
      remoteASN = 4242422034;
      latencyMs = 1;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 22034;
        remoteAddress = "45.76.55.70";
        remotePort = 22547;
        wireguardPubkey = "Zl72hWVO9Ib3ylYqKpDCEq8VyiJjY0WDhXP+vX+CzFs=";
      };
      addressing = {
        peerIPv4 = "172.21.104.33";
        peerIPv6LinkLocal = "fe80::2034";
      };
    };
  };
}
