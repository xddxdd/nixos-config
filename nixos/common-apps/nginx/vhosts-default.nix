{
  lib,
  LT,
  ...
}:
let
  prometheusConf = ''
    vhost_traffic_status_display;
    vhost_traffic_status_display_format prometheus;

    ${lib.concatMapStringsSep "\n" (ip: "allow ${ip};") (
      LT.constants.reserved.IPv4 ++ LT.constants.reserved.IPv6
    )}
    allow 127.0.0.1;
    allow ::1;
    deny all;

    error_page 403 =444;
  '';
in
{
  lantian.nginxVhosts = {
    "_default_http" = {
      listenHTTP.enable = true;
      listenHTTP.default = true;
      listenHTTPS.enable = false;

      locations = {
        "/".return = "301 https://$host$request_uri";
        "/generate_204".return = "204";
        "/metrics".extraConfig = prometheusConf;
      };

      enableCommonLocationOptions = false;
      enableCommonVhostOptions = false;

      extraConfig = ''
        access_log off;
      '';
    };

    "_default_https" = {
      listenHTTPS.default = true;

      locations = {
        "/".return = "444";
        "/generate_204".return = "204";
        "/metrics".extraConfig = prometheusConf;
      };

      enableCommonLocationOptions = false;
      enableCommonVhostOptions = false;

      extraConfig = ''
        access_log off;
      '';
    };

    "localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;
      root = "/var/www/localhost";
      enableCommonLocationOptions = false;
      accessibleBy = "localhost";
    };
  };
}
