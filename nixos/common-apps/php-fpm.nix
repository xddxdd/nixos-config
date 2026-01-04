{ pkgs, ... }:
let
  qqwryDB = pkgs.fetchurl {
    url = "https://github.com/out0fmemory/qqwry.dat/raw/master/qqwry_lastest.dat";
    hash = "sha256-ZfzgGSd+hOIFvqAgKE6GajZwN4GaDRx+awqYwMPh5kI=";
  };
in
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
  };

  systemd.tmpfiles.settings = {
    qqwry = {
      "/etc/qqwry".d = {
        mode = "755";
        user = "root";
        group = "root";
      };
      "/etc/qqwry/qqwry.dat"."L+" = {
        argument = toString qqwryDB;
      };
    };
  };
}
