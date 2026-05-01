{
  config,
  ...
}:
{
  lantian.nginxVhosts."witchsweapon.${config.networking.hostName}.xuyh0120.win" = {
    root = "/var/www/witchsweapon.${config.networking.hostName}.xuyh0120.win";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
    accessibleBy = "private";
  };
}
