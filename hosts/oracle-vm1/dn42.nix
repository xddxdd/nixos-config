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
