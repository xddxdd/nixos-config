{ LT, ... }:
{
  lantian.nginxVhosts = {
    "hydra.lantian.pub" = {
      locations = {
        "/" = {
          proxyPass = "http://${LT.hosts.lt-home-builder.ltnet.IPv4}:${LT.portStr.Hydra}";
        };
      };

      blockDotfiles = false;
      sslCertificate = "zerossl-lantian.pub";
      noIndex.enable = true;
    };
  };
}
