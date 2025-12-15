{
  config,
  LT,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.lantian.pub";
    listenHost = LT.this.ltnet.IPv4;
    notificationSender = "postmaster@lantian.pub";
    port = LT.port.Hydra;
  };

  lantian.nginxVhosts = {
    "hydra.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Hydra}";
        };
      };

      blockDotfiles = false;
      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
  };
}
