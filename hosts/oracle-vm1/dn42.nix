{ config, pkgs, ... }:

{
  age.secrets.dn42-pingfinder-uuid.file = pkgs.secrets + "/dn42-pingfinder/${config.networking.hostName}.age";
  services."dn42-pingfinder".uuidFile = config.age.secrets.dn42-pingfinder-uuid.path;

  services.dn42 = {
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
        remoteAddress = "dn42-tyo-jp-1.ffeeco.coffee";
        remotePort = 22547;
        wireguardPubkey = "UfMRvQLt7xXDMxixjVuDNSinS1bBcmkqEcOrDAqR90c=";
      };
      addressing = {
        peerIPv4 = "172.22.162.135";
        peerIPv6LinkLocal = "fe80::8c7:62ff:feaa:fc47";
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
  };
}
