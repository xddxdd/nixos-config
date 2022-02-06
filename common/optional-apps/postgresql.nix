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

  systemd.services.postgresql.serviceConfig = LT.serviceHarden;

  age.secrets.phppgadmin-conf = {
    file = ../../secrets/phppgadmin-conf.age;
    owner = "nginx";
    group = "nginx";
  };
  systemd.tmpfiles.rules = [
    "L+ /etc/phppgadmin/config.inc.php - - - - ${config.age.secrets.phppgadmin-conf.path}"
  ];
  services.nginx.virtualHosts."pga.lantian.pub" = pkgs.lib.mkIf config.lantian.enable-php {
    listen = LT.nginx.listenHTTPS;
    root = "${pkgs.phppgadmin}";
    locations = LT.nginx.addCommonLocationConf {
      "/".index = "index.php";
    };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex;
  };
}
