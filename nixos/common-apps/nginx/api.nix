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

      "/geoip" = {
        return =
          let
            # Fields will be dynamically replaced by nginx
            json = builtins.toJSON {
              ip = "$remote_addr";
              continent_code = "$geoip2_continent_code";
              continent_name_en = "$geoip2_continent_name_en";
              continent_name_zh = "$geoip2_continent_name_zh";
              country_code = "$geoip2_country_code";
              country_name_en = "$geoip2_country_name_en";
              country_name_zh = "$geoip2_country_name_zh";
              city_name_en = "$geoip2_city_name_en";
              city_name_zh = "$geoip2_city_name_zh";
              postal_code = "$geoip2_postal_code";
              asn_code = "$geoip2_asn_code";
              asn_name = "$geoip2_asn_name";
            };
          in
          "200 '${json}'";
        extraConfig = ''
          default_type application/json;
        '';
      };

      "/ip" = {
        return = "200 $remote_addr";
        extraConfig = ''
          default_type text/plain;
        '';
      };
    };

    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };
}
