{ LT, ... }:
{
  virtualisation.oci-containers.containers = {
    asf = {
      extraOptions = [ "--pull=always" ];
      image = "justarchi/archisteamfarm:released";
      ports = [ "${LT.this.ltnet.IPv4}:${LT.portStr.ASF}:1242" ];
      volumes = [ "/var/lib/asf:/app/config" ];
    };
    gameshub = {
      extraOptions = [ "--pull=always" ];
      image = "lupohan44/games_hub";
      volumes = [ "/var/lib/gameshub:/home/wd" ];
    };
  };

  lantian.nginxVhosts."asf.xuyh0120.win" = {
    locations = {
      "/" = {
        enableOAuth = true;
        proxyPass = "http://${LT.this.ltnet.IPv4}:${LT.portStr.ASF}";
      };
      "~* /Api/NLog" = {
        enableOAuth = true;
        proxyPass = "http://${LT.this.ltnet.IPv4}:${LT.portStr.ASF}";
        proxyWebsockets = true;
      };
    };

    sslCertificate = "xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
