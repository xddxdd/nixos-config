{ config, ... }:

{
  services.dn42 = {
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
