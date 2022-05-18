{ config, ... }:

{
  services.dn42 = {
    baiyu = {
      remoteASN = 4242421901;
      latencyMs = 2;
      peering.mpbgp = true;
      tunnel = {
        type = "wireguard";
        localPort = 21901;
        remoteAddress = "node1.vultr.nrt.asia.dn42.dalao-home.com";
        remotePort = 22547;
        wireguardPubkey = "KYnacNZP+hZtLsbhUhKjrREFbxKIPKZqtO8P3kaptTs=";
      };
      addressing = {
        peerIPv4 = "172.23.221.69";
        peerIPv6LinkLocal = "fe80::1901:3921:0:1";
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
  };
}
