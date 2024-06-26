_: {
  lantian.nginxVhosts."api.lantian.pub" = {
    root = "/var/empty";
    locations = {
      # https://soha.moe/post/test-capport-rfc.html
      "= /captive-portal" = {
        return =
          let
            json = builtins.toJSON {
              captive = false;
              venue-info-url = "https://lantian.pub";
              seconds-remaining = 10 * 365 * 24 * 60 * 60; # 10 years
              bytes-remaining = 1024 * 1024 * 1024 * 1024 * 1024; # 1 PB
              can-extend-session = false;
            };
          in
          "200 '${json}'";
        extraConfig = ''
          default_type application/captive+json;
        '';
      };
    };

    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };
}
