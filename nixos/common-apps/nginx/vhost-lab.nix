{
  config,
  ...
}:
{
  lantian.nginxVhosts."lab.${config.networking.hostName}.xuyh0120.win" = {
    root = "/var/www/lab.${config.networking.hostName}.xuyh0120.win";
    locations."/".enableAutoIndex = true;
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
    accessibleBy = "private";
  };
}
