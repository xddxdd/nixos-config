{ LT, ... }:
{
  lantian.nginxVhosts = {
    "hydra.lantian.pub" = {
      locations = {
        "/" = {
          proxyPass = "http://${LT.hosts.pve-epyc.ltnet.IPv4}:${LT.portStr.Hydra}";
          extraConfig = ''
            limit_req zone=slow burst=20 nodelay;
            limit_req_status 429;
          '';
        };
      };

      blockDotfiles = false;
      enableCommonLocationOptions = false;
      sslCertificate = "zerossl-lantian.pub";
      noIndex.enable = true;
    };
  };
}
