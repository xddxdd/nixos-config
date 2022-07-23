{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  age.secrets.minio-admin = {
    file = pkgs.secrets + "/minio-admin.age";
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
      + LT.nginx.noIndex true;
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
      + LT.nginx.noIndex true;
  };
}
