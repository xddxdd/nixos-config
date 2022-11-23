{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../helpers args;
in
{
  age.secrets.minio-admin = {
    file = inputs.secrets + "/minio-admin.age";
    owner = "minio";
    group = "minio";
  };

  services.minio = {
    enable = true;
    listenAddress = "127.0.0.1:${LT.portStr.Minio.Listen}";
    consoleAddress = "127.0.0.1:${LT.portStr.Minio.Console}";
    rootCredentialsFile = config.age.secrets.minio-admin.path;
  };

  services.nginx.virtualHosts."minio.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { } {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Minio.Console}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true
      + ''
      client_body_buffer_size 512k;
      client_body_timeout 52w;
      client_max_body_size 0;
    '';
  };

  services.nginx.virtualHosts."s3.xuyh0120.win" = {
    listen = LT.nginx.listenHTTPS;
    locations = LT.nginx.addCommonLocationConf { } {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Minio.Listen}";
        extraConfig = LT.nginx.locationProxyConf;
      };
    };
    extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true
      + ''
      access_log off;
      client_body_buffer_size 512k;
      client_body_timeout 52w;
      client_max_body_size 0;
    '';
  };
}
