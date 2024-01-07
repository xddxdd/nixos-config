{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  lantian.nginxVhosts."private.xuyh0120.win" = {
    root = "/var/www/private.xuyh0120.win";
    locations = {
      "/".index = "index.html";
    };

    sslCertificate = "xuyh0120.win_ecc";
    noIndex.enable = true;
    accessibleBy = "private";
  };
}
