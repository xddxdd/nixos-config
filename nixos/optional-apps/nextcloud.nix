{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  overrideConfigPath = lib.last (
    lib.splitString " " (
      builtins.head (builtins.filter (lib.hasInfix "override.config.php") config.systemd.tmpfiles.rules)
    )
  );
  oracleCaBundle = config.environment.etc."pki/tls/cert.pem".source;
in
{
  sops.secrets.dex-nextcloud-secret = {
    sopsFile = inputs.secrets + "/dex/nextcloud.yaml";
    owner = "nextcloud";
    group = "nextcloud";
  };
  sops.secrets.nextcloud-admin-pw = {
    sopsFile = inputs.secrets + "/nextcloud.yaml";
    mode = "0444";
  };
  sops.secrets.nextcloud-dbpw = {
    sopsFile = inputs.secrets + "/nextcloud.yaml";
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
    package = pkgs.nextcloud35;
    autoUpdateApps.enable = true;
    caching = {
      apcu = true;
      redis = true;
    };
    config = {
      dbtype = "oci";
      dbhost = "";
      dbname = "(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1521)(host=adb.ap-tokyo-1.oraclecloud.com))(connect_data=(service_name=ufjybiswtxi7xyl_lantianfree_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))";
      dbuser = "admin";
      dbpassFile = config.sops.secrets.nextcloud-dbpw.path;
    };
    hostName = "cloud.xuyh0120.win";
    https = true;
    webfinger = true;

    appstoreEnable = false;
    extraApps = {
      inherit (pkgs.nextcloud35Packages.apps)
        calendar
        checksum
        contacts
        oidc_login
        tasks
        ;
    };

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

      mail_domain = "lantian.pub";
      mail_smtpmode = "sendmail";
      mail_sendmailmode = "pipe";

      allow_user_to_change_display_name = false;
      lost_password_link = "disabled";
      oidc_login_provider_url = "https://login.lantian.pub";
      oidc_login_end_session_redirect = false;
      oidc_login_client_id = "nextcloud";
      oidc_login_auto_redirect = true;
      oidc_login_hide_password_form = true;
      oidc_login_use_id_token = true;
      oidc_login_attributes = {
        id = "preferred_username";
        name = "name";
        mail = "email";
        groups = "groups";
      };
      oidc_login_scope = "openid profile email groups";
      oidc_login_code_challenge_method = "S256";
    };
    secrets = {
      oidc_login_client_secret = config.sops.secrets.dex-nextcloud-secret.path;
    };
  };
  sops.secrets.smtp-pass.restartUnits = [ "phpfpm-nextcloud.service" ];

  # The upstream module publishes config overrides as an L+ tmpfiles symlink
  # into /nix/store; the phpfpm pool unit picks up the target via
  # restartTriggers, but nextcloud-cron / nextcloud-update-db don't reference
  # it in their own unit text, so their confinement closure misses it and php
  # dies with "FATAL: Could not open the config file". Pull the symlink target
  # into their chroots explicitly.

  systemd.services.phpfpm-nextcloud.path = [ pkgs.msmtp ];
  systemd.services.phpfpm-nextcloud.serviceConfig = {
    RestartSec = "5s";
    BindReadOnlyPaths = [ config.sops.secrets.smtp-pass.path ];
    # Workers read/write the whole Nextcloud tree (config.php, data/, previews)
    BindPaths = [ config.services.nextcloud.datadir ];
    # Recreate /run/phpfpm-nextcloud on every start: it must always be owned
    # by the unit user, and the socket has no value while workers restart
    # with the master anyway.
    RuntimeDirectoryPreserve = lib.mkForce false;
  };
  # Run the whole pool as the nextcloud user: socket, runtime dir and the
  # upstream credential-copy preStart all end up owned by that single user,
  # so the confined master needs no ownership-shuffling capabilities. nginx
  # reaches the socket through the nextcloud group.
  services.phpfpm.pools.nextcloud.masterUser = "nextcloud";
  services.nextcloud.poolSettings = {
    "listen.owner" = "nextcloud";
    "listen.group" = "nextcloud";
    # Same ondemand shape as calibre-cops: idle-scaled workers on the
    # low-traffic private instance
    "pm" = "ondemand";
    "pm.max_children" = "8";
    "pm.max_requests" = "1000";
    "pm.process_idle_timeout" = "10s";
    "request_terminate_timeout" = "300";
    "pm.status_path" = "/status";
  };
  lantian.harden.phpfpm-nextcloud = {
    etc.msmtprc = true;
    # Oracle instant client requires the CERTIFICATE-only bundle; bind the
    # generated bundle directly, like the harden /etc/ssl defaults do
    etc."pki/tls/cert.pem" = oracleCaBundle;
    redis = "nextcloud";
  };
  systemd.services.nextcloud-cron = {
    path = [ pkgs.msmtp ];
    confinement.packages = [ overrideConfigPath ];
    serviceConfig = {
      BindReadOnlyPaths = [
        "${config.environment.etc.msmtprc.source}:/etc/msmtprc"
        config.sops.secrets.smtp-pass.path
      ];
      BindPaths = [ config.services.nextcloud.datadir ];
      # PHP's JIT emits executable memory
      MemoryDenyWriteExecute = false;
    };
  };
  lantian.harden.nextcloud-cron = {
    enable = true;
    passwd = true;
    etc."nsswitch.conf" = true;
    # Oracle instant client requires the CERTIFICATE-only bundle; bind the
    # generated bundle directly, like the harden /etc/ssl defaults do
    etc."pki/tls/cert.pem" = oracleCaBundle;
    redis = "nextcloud";
  };
  lantian.harden.nextcloud-update-db = {
    enable = true;
    passwd = true;
    etc."nsswitch.conf" = true;
    etc."pki/tls/cert.pem" = oracleCaBundle;
    redis = "nextcloud";
  };
  systemd.services.nextcloud-update-db = {
    confinement.packages = [ overrideConfigPath ];
    # PHP's JIT emits executable memory
    serviceConfig = {
      BindPaths = [ config.services.nextcloud.datadir ];
      MemoryDenyWriteExecute = false;
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
    accessibleBy = "private";
    sslCertificate = "lets-encrypt-xuyh0120.win";
    enableCommonLocationOptions = false;
    enableCommonVhostOptions = false;
  };
}
