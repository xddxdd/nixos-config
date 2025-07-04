{ LT, ... }:
{
  virtualisation.oci-containers.containers.asf = {
    extraOptions = [ "--pull=always" ];
    image = "justarchi/archisteamfarm:released";
    ports = [ "${LT.this.ltnet.IPv4}:${LT.portStr.ASF}:1242" ];
    volumes = [
      "/var/lib/asf/config:/app/config"
      "/var/lib/asf/plugins:/app/plugins"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/asf 755 1000 1000"
    "d /var/lib/asf/config 755 1000 1000"
    "d /var/lib/asf/plugins 755 1000 1000"
  ];

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

    sslCertificate = "lets-encrypt-xuyh0120.win";
    noIndex.enable = true;
  };
}
