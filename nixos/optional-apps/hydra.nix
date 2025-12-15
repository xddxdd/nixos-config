{
  config,
  LT,
  ...
}:
{
  imports = [ ./postgresql.nix ];

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.${config.networking.hostName}.xuyh0120.win";
    listenHost = "localhost";
    notificationSender = "postmaster@lantian.pub";
    port = LT.port.Hydra;
  };

  lantian.nginxVhosts = {
    "hydra.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Hydra}";
        };
      };

      accessibleBy = "private";
      blockDotfiles = false;
      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
    };
  };
}
