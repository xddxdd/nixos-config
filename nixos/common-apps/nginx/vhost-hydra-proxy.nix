{ lib, LT, ... }:
lib.mkIf (LT.this.hasTag LT.tags.public-facing) {
  lantian.nginxVhosts = {
    "hydra.lantian.pub" = {
      locations = {
        "/" = {
          proxyPass = "http://${LT.hosts.pve-epyc.ltnet.IPv4}:${LT.portStr.Hydra.WebUI}";
          blockBadUserAgents = true;
          blockBadTLSSignatures = true;
          extraConfig = ''
            limit_req zone=slow burst=20 nodelay;
            limit_req_status 429;
          '';
        };
        # hydra-ws live build log streaming, from the ws_endpoint in hydra.conf
        "/ws" = {
          proxyPass = "http://${LT.hosts.pve-epyc.ltnet.IPv4}:${LT.portStr.Hydra.WebSocket}";
          proxyWebsockets = true;
        };
      };

      blockDotfiles = false;
      enableCommonLocationOptions = false;
      sslCertificate = "zerossl-lantian.pub";
      noIndex.enable = true;
    };
  };
}
