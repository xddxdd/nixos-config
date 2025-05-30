_: {
  lantian.nginxVhosts."private.xuyh0120.win" = {
    root = "/var/www/private.xuyh0120.win";
    locations = {
      "/".index = "index.html";
    };

    sslCertificate = "lets-encrypt-xuyh0120.win";
    noIndex.enable = true;
    accessibleBy = "private";
  };
}
