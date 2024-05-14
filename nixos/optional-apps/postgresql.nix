{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16_jit;
    settings.listen_addresses = lib.mkForce (
      lib.concatStringsSep ", " [
        "127.0.0.1"
        "::1"
        LT.this.ltnet.IPv4
        LT.this.ltnet.IPv6
      ]
    );
    authentication = ''
      host all all 198.18.0.0/15 md5
      host all all fdbc:f9dc:67ad::/48 md5
    '';
  };

  systemd.services.postgresql.serviceConfig = LT.serviceHarden;

  services.phpfpm.pools.pga = {
    phpPackage = pkgs.php.withExtensions (
      { enabled, all }:
      with all;
      enabled
      ++ [
        pdo
        pdo_pgsql
        pgsql
      ]
    );
    inherit (config.services.nginx) user;
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "ondemand";
      "pm.max_children" = "8";
      "pm.process_idle_timeout" = "10s";
      "pm.max_requests" = "1000";
      "pm.status_path" = "/php-fpm-status.php";
      "ping.path" = "/ping.php";
      "ping.response" = "pong";
      "request_terminate_timeout" = "300";
    };
  };

  age.secrets.phppgadmin-conf = {
    file = inputs.secrets + "/phppgadmin-conf.age";
    owner = "nginx";
    group = "nginx";
  };
  systemd.tmpfiles.rules = [
    "L+ /etc/phppgadmin/config.inc.php - - - - ${config.age.secrets.phppgadmin-conf.path}"
  ];
  lantian.nginxVhosts = {
    "pga.${config.networking.hostName}.xuyh0120.win" = {
      root = pkgs.phppgadmin;
      locations = {
        "/".index = "index.php";
      };

      phpfpmSocket = config.services.phpfpm.pools.pga.socket;
      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "pga.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      root = pkgs.phppgadmin;
      locations = {
        "/".index = "index.php";
      };

      phpfpmSocket = config.services.phpfpm.pools.pga.socket;
      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    port = LT.port.Prometheus.PostgresExporter;
    listenAddress = LT.this.ltnet.IPv4;
    runAsLocalSuperUser = true;
  };
}
