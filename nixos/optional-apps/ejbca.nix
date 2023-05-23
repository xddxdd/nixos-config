{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  virtualisation.oci-containers.containers.ejbca = {
    extraOptions = ["--pull" "always"];
    image = "keyfactor/ejbca-ce:latest";
    ports = [
      "${LT.this.ltnet.IPv4}:${LT.portStr.EJBCA.HTTP}:80"
      "${LT.this.ltnet.IPv4}:${LT.portStr.EJBCA.HTTPS}:443"
    ];
  };

  services.nginx.virtualHosts."asf.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf {} {
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
    extraConfig =
      LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
