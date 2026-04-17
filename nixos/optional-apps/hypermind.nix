{ LT, config, ... }:
{
  virtualisation.oci-containers.containers.hypermind = {
    extraOptions = [ "--net=host" ];
    image = "ghcr.io/lklynet/hypermind:latest";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    environment = {
      PORT = LT.portStr.Hypermind;
      ENABLE_CHAT = "true";
      ENABLE_MAP = "true";
    };
  };

  lantian.nginxVhosts."hypermind.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Hypermind}";
      };
    };

    accessibleBy = "private";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
