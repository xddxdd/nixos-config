{ config, pkgs, ... }:

{
  services.phpfpm = {
    phpOptions = ''
      engine = On
      short_open_tag = On
      precision = 14
      output_buffering = Off
      zlib.output_compression = Off
      implicit_flush = Off
      unserialize_callback_func =
      serialize_precision = 17
      disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,
      disable_classes =
      zend.enable_gc = On
      zend.multibyte = On
      expose_php = Off
      max_execution_time = 300
      max_input_time = 300
      memory_limit = 256M
      error_reporting = E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED
      display_errors = On
      display_startup_errors = Off
      log_errors = On
      log_errors_max_len = 1024
      ignore_repeated_errors = Off
      ignore_repeated_source = Off
      report_memleaks = On
      track_errors = Off
      html_errors = On
      variables_order = "GPCS"
      request_order = "GP"
      register_argc_argv = Off
      auto_globals_jit = On
      post_max_size = 100M
      auto_prepend_file =
      auto_append_file =
      default_mimetype = "text/html"
      default_charset = "UTF-8"
      doc_root =
      user_dir =
      enable_dl = Off
      file_uploads = On
      upload_max_filesize = 100M
      max_file_uploads = 20
      allow_url_fopen = On
      allow_url_include = Off
      default_socket_timeout = 60
    '';

    # phpPackage = pkgs.php.withExtensions ({ enabled, all }: builtins.filter (v: !v.meta.broken) (pkgs.lib.attrValues all));
    phpPackage = pkgs.php.withExtensions ({ enabled, all }: with all; enabled ++ [
      gd zip xml pdo gmp ftp ffi dom bz2 zlib yaml exif curl apcu redis pgsql iconv event
      ctype sodium mysqli sockets openssl mysqlnd imagick gettext readline protobuf mbstring
      sqlite3 memcached maxminddb pdo_pgsql pdo_mysql pdo_sqlite
    ]);

    pools = {
      www = pkgs.lib.mkIf config.lantian.enable-php {
        user = config.services.nginx.user;
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
    };
  };
}
