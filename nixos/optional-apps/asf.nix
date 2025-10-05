{ LT, ... }:
{
  virtualisation.oci-containers.containers.asf = {
    image = "docker.io/justarchi/archisteamfarm:released";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    ports = [ "${LT.this.ltnet.IPv4}:${LT.portStr.ASF}:1242" ];
    volumes = [
      "/var/lib/asf/config:/app/config"
      "/var/lib/asf/plugins:/app/plugins"
    ];
  };

  systemd.tmpfiles.settings = {
    asf = {
      "/var/lib/asf"."d" = {
        mode = "755";
        user = "1000";
        group = "1000";
      };
      "/var/lib/asf/config"."d" = {
        mode = "755";
        user = "1000";
        group = "1000";
      };
      "/var/lib/asf/plugins"."d" = {
        mode = "755";
        user = "1000";
        group = "1000";
      };
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

    sslCertificate = "zerossl-xuyh0120.win";
    noIndex.enable = true;
  };
}
