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
        sslCertificate = "xuyh0120.win";
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
      $config['cops_kepubify_path'] = '${pkgs.kepubify}/bin/kepubify';
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
  };
}
