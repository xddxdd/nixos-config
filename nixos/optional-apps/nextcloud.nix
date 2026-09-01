{
  pkgs,
  config,
  inputs,
  ...
}:
{
  sops.secrets.remote-db-pw = {
    sopsFile = inputs.secrets + "/common/remote-db-pw.yaml";
    mode = "0444";
  };

  # Oracle instant client's system-cert loader (nzcrp_osl_LoadSystemCerts) segfaults on
  # "BEGIN TRUSTED CERTIFICATE" blocks (OpenSSL-specific format) present in the default
  # NixOS CA bundle. The client checks /etc/pki/tls/cert.pem first, so provide a copy with
  # only plain CERTIFICATE blocks there; it never falls back to the crashing bundle.
  environment.etc."pki/tls/cert.pem".source = pkgs.runCommand "oracle-ca-cert.pem" { } ''
    awk '/^-----BEGIN CERTIFICATE-----/{p=1} p{print} /^-----END CERTIFICATE-----/{p=0}' ${config.security.pki.caBundle} > $out
  '';

  environment.systemPackages = [ config.services.nextcloud.occ ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud34;
    autoUpdateApps.enable = true;
    caching = {
      apcu = true;
      redis = true;
    };
    config = {
      adminpassFile = config.sops.secrets.default-pw.path;
      adminuser = "lantian";
      dbtype = "oci";
      dbhost = "";
      dbname = "(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=adb.ap-tokyo-1.oraclecloud.com))(connect_data=(service_name=ufjybiswtxi7xyl_lantianfree_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))";
      dbuser = "admin";
      dbpassFile = config.sops.secrets.remote-db-pw.path;
    };
    hostName = "cloud.xuyh0120.win";
    https = true;
    webfinger = true;

    phpOptions = {
      "opcache.memory_consumption" = 512;
      "opcache.interned_strings_buffer" = 64;
    };
    phpExtraExtensions = all: [
      all.oci8
    ];

    settings = {
      default_phone_region = "CN";
      overwriteprotocol = "https";
      "integrity.check.disabled" = true;
      maintenance_window_start = 1;
    };
  };

  services.redis.servers.nextcloud = {
    enable = true;
    port = 0;
    databases = 1;
    inherit (config.services.phpfpm.pools.nextcloud) user;
  };
  systemd.services.redis-nextcloud.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };

  lantian.nginxVhosts."cloud.xuyh0120.win" = {
    # Nextcloud sends "X-Robots-Tag: none" itself, no need for noIndex
    sslCertificate = "zerossl-xuyh0120.win";
    enableCommonLocationOptions = false;
    enableCommonVhostOptions = false;
  };
}
