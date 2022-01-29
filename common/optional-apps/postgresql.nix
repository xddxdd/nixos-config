{ pkgs, config, ... }:

let
  LT = import ../helpers.nix {  inherit config pkgs; };
in
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
  };

  services.postgresqlBackup = {
    enable = true;
    compression = "zstd";
  };

  services.nginx.virtualHosts."pga.lantian.pub" = pkgs.lib.mkIf config.lantian.enable-php {
    listen = LT.nginx.listenHTTPS;
    root = "/var/www/pga.lantian.pub";
    locations = LT.nginx.addCommonLocationConf {
      "/" = {
        index = "index.php";
      };
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
