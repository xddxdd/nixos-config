{
  pkgs,
  lib,
  config,
  options,
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

    lantian.nginxVhosts = {
      "books.xuyh0120.win" = {
        root = pkgs.nur-xddxdd.calibre-cops;
        locations = {
          "/" = {
            index = "index.php";
            enableBasicAuth = true;
          };
          "/download/".extraConfig = ''
            rewrite ^/download/(\d+)/(\d+)/.*\.kepub\.epub$ /fetch.php?data=$1&db=$2&type=epub last;
            rewrite ^/download/(\d+)/(\d+)/.*\.(.*)$ /fetch.php?data=$1&db=$2&type=$3 last;
            rewrite ^/download/(\d+)/.*\.kepub\.epub$ /fetch.php?data=$1&type=epub last;
            rewrite ^/download/(\d+)/.*\.(.*)$ /fetch.php?data=$1&type=$2 last;
            break;
          '';
          "/view/".extraConfig = ''
            rewrite ^/view/(\d+)/(\d+)/.*\.kepub\.epub$ /fetch.php?data=$1&db=$2&type=epub&view=1 last;
            rewrite ^/view/(\d+)/(\d+)/.*\.(.*)$ /fetch.php?data=$1&db=$2&type=$3&view=1 last;
            rewrite ^/view/(\d+)/.*\.kepub\.epub$ /fetch.php?data=$1&type=epub&view=1 last;
            rewrite ^/view/(\d+)/.*\.(.*)$ /fetch.php?data=$1&type=$2&view=1 last;
            break;
          '';
          "\"${calibreLibrary}/\"".extraConfig = ''
            alias "${calibreLibrary}/";
            internal;
          '';
        };

        phpfpmSocket = config.services.phpfpm.pools.calibre-cops.socket;
        sslCertificate = "xuyh0120.win_ecc";
      };
    };

    environment.etc."calibre-cops/config_local.php".text = ''
      <?php
      if (!isset($config)) {
        $config = array();
      }
      $config['calibre_directory'] = '${calibreLibrary}/';
      $config['calibre_internal_directory'] = '/calibre/';
      $config['cops_full_url'] = 'https://books.xuyh0120.win/';
      $config['cops_title_default'] = 'Lan Tian @ Books';
      $config['default_timezone'] = '${config.time.timeZone}';
      $config['cops_x_accel_redirect'] = "X-Accel-Redirect";
      $config['cops_prefered_format'] = array('EPUB', 'PDF', 'TXT');
      $config['cops_use_url_rewriting'] = "1";
      $config['cops_generate_invalid_opds_stream'] = '1';
      $config['cops_author_split_first_letter'] = '0';
      $config['cops_titles_split_first_letter'] = '0';
      $config['cops_use_fancyapps'] = '0';
      $config['cops_provide_kepub'] = '1';
      $config['cops_ignored_categories'] = array('publisher', 'rating');
      $config['cops_use_route_urls'] = '1';
      $config['cops_epub_reader'] = 'epubjs';
    '';
  };
}
