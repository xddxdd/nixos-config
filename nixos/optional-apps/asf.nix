{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  virtualisation.oci-containers.containers = {
    asf = {
      extraOptions = ["--pull" "always"];
      image = "justarchi/archisteamfarm:released";
      ports = [
        "${LT.this.ltnet.IPv4}:${LT.portStr.ASF}:1242"
      ];
      volumes = [
        "/var/lib/asf:/app/config"
      ];
    };
    gameshub = {
      extraOptions = ["--pull" "always"];
      image = "lupohan44/games_hub";
      volumes = [
        "/var/lib/gameshub:/home/wd"
      ];
    };
  };

  lantian.nginxVhosts."asf.xuyh0120.win" = {
    locations = {
      "/".extraConfig =
        LT.nginx.locationOauthConf
        + ''
          proxy_pass http://${LT.this.ltnet.IPv4}:${LT.portStr.ASF};
        ''
        + LT.nginx.locationProxyConf;
      "~* /Api/NLog".extraConfig =
        LT.nginx.locationOauthConf
        + ''
          proxy_pass http://${LT.this.ltnet.IPv4}:${LT.portStr.ASF};
          proxy_http_version 1.1;
          proxy_set_header Connection "upgrade";
          proxy_set_header Upgrade $http_upgrade;
        ''
        + LT.nginx.locationProxyConf;
    };

    sslCertificate = "xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
