{
  pkgs,
  lib,
  config,
  LT,
  ...
}:
let
  calibreLibrary = config.services.calibre-cops.libraryPath;
in
{
  options.services.calibre-cops = {
    libraryPath = lib.mkOption {
      type = lib.types.path;
      default = "/nix/persistent/media/Calibre Library";
      description = "Path to calibre library";
    };
  };

  config = {
    systemd.services.phpfpm-calibre-cops.unitConfig.RequiresMountsFor = [
      (LT.escapeMountPath calibreLibrary)
    ];
    systemd.services.nginx.unitConfig.RequiresMountsFor = [ (LT.escapeMountPath calibreLibrary) ];
    # nginx confinement: bind the calibre library read-only for the internal
    # X-Accel alias
    systemd.services.nginx.serviceConfig.BindReadOnlyPaths = [
      (LT.escapeMountPath calibreLibrary)
    ];

    services.phpfpm.pools.calibre-cops = {
      phpPackage = pkgs.php.withExtensions (
        { enabled, all }:
        with all;
        enabled
        ++ [
          gd
          intl
          sqlite3
          xml
        ]
      );
      inherit (config.services.nginx) user;
      settings = {
        "listen.owner" = config.services.nginx.user;
        "ping.path" = "/ping.php";
        "ping.response" = "pong";
        "pm.max_children" = "8";
        "pm.max_requests" = "1000";
        "pm.process_idle_timeout" = "10s";
        "pm" = "ondemand";
        "request_terminate_timeout" = "300";
      };
    };

    lantian.nginxVhosts = {
      "books.xuyh0120.win" = {
        root = pkgs.nur-xddxdd.calibre-cops;
        # Keep off the public internet; basic auth already required
        accessibleBy = "private";
        locations = {
          "/" = {
            tryFiles = "$uri $uri/ /index.php$uri";
            index = "index.php";
            enableBasicAuth = true;
          };
          "/download/".extraConfig = ''
            rewrite ^/download/(\d+)/(\d+)/.*\.(.*)$ /index.php/fetch/$2/$1/ignore.$3 last;
            rewrite ^/download/(\d+)/.*\.(.*)$ /index.php/fetch/0/$1/ignore.$2 last;
            break;
          '';
          "/view/".extraConfig = ''
            rewrite ^/view/(\d+)/(\d+)/.*\.(.*)$ /index.php/inline/$2/$1/ignore.$3 last;
            rewrite ^/view/(\d+)/.*\.(.*)$ /index.php/inline/0/$1/ignore.$2 last;
            break;
          '';
          "\"${calibreLibrary}/\"".extraConfig = ''
            alias "${calibreLibrary}/";
            internal;
          '';
        };

        phpfpmSocket = config.services.phpfpm.pools.calibre-cops.socket;
        sslCertificate = "lets-encrypt-xuyh0120.win";
      };
    };

    environment.etc."calibre-cops/config_local.php".text = ''
      <?php
      if (!isset($config)) {
        $config = array();
      }
      $config['calibre_directory'] = '${calibreLibrary}/';
      $config['calibre_internal_directory'] = '/books/';
      $config['cops_author_split_first_letter'] = '0';
      $config['cops_epub_reader'] = 'epubjs';
      # $config['cops_front_controller'] = 'index.php';
      $config['cops_full_url'] = 'https://books.xuyh0120.win/';
      $config['cops_generate_invalid_opds_stream'] = '1';
      $config['cops_ignored_categories'] = array('publisher', 'rating');
      $config['cops_kepubify_path'] = '${lib.getExe' pkgs.kepubify "kepubify"}';
      $config['cops_max_item_per_page'] = '-1';
      $config['cops_prefered_format'] = array('EPUB', 'PDF', 'TXT');
      $config['cops_provide_kepub'] = '1';
      # $config['cops_server_side_render'] = '.';
      $config['cops_template'] = 'bootstrap5';
      $config['cops_title_default'] = 'Lan Tian @ Books';
      $config['cops_titles_split_first_letter'] = '0';
      $config['cops_use_fancyapps'] = '0';
      # $config['cops_use_url_rewriting'] = '1';
      $config['cops_x_accel_redirect'] = "X-Accel-Redirect";
      $config['default_timezone'] = '${config.time.timeZone}';
    '';

    # phpfpm-calibre-cops: hardening keys + confinement; chroot's tmpfs root
    # is ephemeral, so bind the host library through
    systemd.services.phpfpm-calibre-cops = {
      serviceConfig = LT.serviceHarden // {
        Restart = "always";
        RestartSec = "5s";
        MemoryDenyWriteExecute = false;

        # php-fpm chowns the FastCGI socket to the pool user; the chown call
        # needs to survive the seccomp filter (@privileged normally denied)
        AmbientCapabilities = [ "CAP_CHOWN" "CAP_FOWNER" ];
        CapabilityBoundingSet = [ "CAP_CHOWN" "CAP_FOWNER" ];
        SystemCallFilter = lib.mkForce [
          "@system-service"
          "~@clock @cpu-emulation @debug @module @obsolete @raw-io @reboot @swap"
        ];

        # php-fpm resolves pool users at runtime; bind passwd/group read-only,
        # plus the library for the internal directory listing
        BindReadOnlyPaths = [
          "/etc/passwd"
          "/etc/group"
          (LT.escapeMountPath calibreLibrary)
        ];
      };

    };
  };
}
