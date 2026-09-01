{
  pkgs,
  LT,
  config,
  ...
}:
let
  officialTheme =
    src:
    pkgs.stdenvNoCC.mkDerivation {
      inherit (src) pname;
      inherit (src) version src;
      nativeBuildInputs = [ pkgs.unzip ];
      installPhase = "mkdir -p $out; cp -r . $out/";
    };
in
{
  imports = [
    ./mysql.nix
    ./fail2ban
  ];

  services.wordpress = {
    webserver = "nginx";
    sites."wp.xuyh0120.win" = {
      database = {
        createLocally = true;
        name = "wordpress";
      };
      settings = {
        WPLANG = "zh_CN";
        # wp-cron.php is triggered by a systemd timer instead
        DISABLE_WP_CRON = true;
      };
      languages = [
        (pkgs.stdenv.mkDerivation {
          name = "language-zh_CN";
          src = pkgs.fetchurl {
            url = "https://zh.wordpress.org/wordpress-${pkgs.wordpress.version}-zh_CN.tar.gz";
            sha256 = "sha256-oAzo/+6mEk4+CYXGN/a61An3GpnSfnfQka56HchhXsE=";
          };
          installPhase = "mkdir -p $out; cp -r ./wp-content/languages/* $out/";
        })
      ];
      plugins = {
        inherit (pkgs.wordpressPackages.plugins) disable-xml-rpc wp-fail2ban wp-fastest-cache;
      };
      themes = {
        twentyten = officialTheme LT.sources.wordpress-theme-twentyten;
        twentyeleven = officialTheme LT.sources.wordpress-theme-twentyeleven;
        twentytwelve = officialTheme LT.sources.wordpress-theme-twentytwelve;
        twentythirteen = officialTheme LT.sources.wordpress-theme-twentythirteen;
        twentyfourteen = officialTheme LT.sources.wordpress-theme-twentyfourteen;
        twentyfifteen = officialTheme LT.sources.wordpress-theme-twentyfifteen;
        twentysixteen = officialTheme LT.sources.wordpress-theme-twentysixteen;
        twentyseventeen = officialTheme LT.sources.wordpress-theme-twentyseventeen;
        inherit (pkgs.wordpressPackages.themes)
          twentynineteen
          twentytwenty
          twentytwentyone
          twentytwentytwo
          twentytwentythree
          twentytwentyfour
          twentytwentyfive
          ;
      };
    };
  };

  # WP fail2ban plugin logs to syslog (identifier "wordpress"); wire the
  # filters shipped by the plugin into fail2ban
  services.fail2ban.jails = {
    wordpress-hard.settings = {
      enabled = true;
      filter = "wordpress-hard";
      journalmatch = "SYSLOG_IDENTIFIER=wordpress";
      port = "http,https";
      maxretry = 1;
      bantime = "24h";
    };
    wordpress-soft.settings = {
      enabled = true;
      filter = "wordpress-soft";
      journalmatch = "SYSLOG_IDENTIFIER=wordpress";
      port = "http,https";
      maxretry = 5;
      bantime = "1h";
    };
  };

  # Run wp-cron.php locally via PHP CLI, instead of WP's default
  # HTTP-triggered cron
  systemd.services.wordpress-cron = {
    after = [ "mysql.service" ];
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      User = "wordpress";
      Group = config.services.nginx.group;
      ReadWritePaths = [
        config.services.wordpress.sites."wp.xuyh0120.win".cacheDir
        config.services.wordpress.sites."wp.xuyh0120.win".uploadsDir
      ];
    };
    # Reuse the php-fpm pool's PHP to guarantee the same extension set
    path = [ config.services.phpfpm.pools."wordpress-wp.xuyh0120.win".phpPackage ];
    script = ''
      php ${config.services.wordpress.sites."wp.xuyh0120.win".finalPackage}/share/wordpress/wp-cron.php
    '';
  };

  systemd.timers.wordpress-cron = {
    wantedBy = [ "timers.target" ];
    partOf = [ "wordpress-cron.service" ];
    timerConfig = {
      OnCalendar = "*:0/5";
      RandomizedDelaySec = "5min";
      Unit = "wordpress-cron.service";
    };
  };

  environment.etc = {
    "fail2ban/filter.d/wordpress-hard.conf".source =
      "${pkgs.wordpressPackages.plugins.wp-fail2ban}/filters.d/wordpress-hard.conf";
    "fail2ban/filter.d/wordpress-soft.conf".source =
      "${pkgs.wordpressPackages.plugins.wp-fail2ban}/filters.d/wordpress-soft.conf";
  };

  lantian.nginxVhosts."wp.xuyh0120.win" = {
    sslCertificate = "zerossl-xuyh0120.win";
  };
}
