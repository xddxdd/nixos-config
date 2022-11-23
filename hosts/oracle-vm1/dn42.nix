{ pkgs, lib, config, utils, inputs, ... }@args:

{
  age.secrets.dn42-pingfinder-uuid.file = inputs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
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
    ffee = {
      remoteASN = 4242423397;
      latencyMs = 9;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 23397;
        # remoteAddress = "dn42-tyo-jp-1.ffeeco.coffee";
        remotePort = 22547;
        wireguardPubkey = "UfMRvQLt7xXDMxixjVuDNSinS1bBcmkqEcOrDAqR90c=";
      };
      addressing = {
        peerIPv4 = "172.22.162.135";
        peerIPv6LinkLocal = "fe80::8c7:62ff:feaa:fc47";
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
    k1t3ab = {
      remoteASN = 4242421591;
      latencyMs = 79;
      # peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21591;
        remoteAddress = "az.kiteab.me";
        remotePort = 22547;
        wireguardPubkey = "eG9V/YHHvzK+1Hv1WoWHaZeRHCrs53rMuR7BoGwvq3A=";
      };
      addressing = {
        peerIPv4 = "172.23.69.192";
        peerIPv6 = "fd41:c44d:1c1e::";
        # peerIPv6LinkLocal = "fe80::1591";
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
    potat0 = {
      remoteASN = 4242421816;
      latencyMs = 4;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21816;
        remoteAddress = "jp1.dn42.potat0.cc";
        remotePort = 22547;
        wireguardPubkey = "Tv1+HniELrS4Br2i7oQgwqBJFXQKculsW8r+UOqQXH0=";
      };
      addressing = {
        peerIPv4 = "172.23.246.2";
        peerIPv6LinkLocal = "fe80::1816";
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
  };
}
