{ pkgs, lib, config, utils, inputs, ... }@args:

let
  LT = import ../../../helpers args;
  inherit (import ./helpers.nix args) compressStaticAssets;
  labRoot = "/var/www/lab.lantian.pub";
in
{
  services.nginx.virtualHosts."lab.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    root = labRoot;
    locations = LT.nginx.addCommonLocationConf
      { phpfpmSocket = config.services.phpfpm.pools.lab.socket; }
      {
        "/" = {
          index = "index.php index.html index.htm";
          tryFiles = "$uri $uri/ =404";
        };
        "= /".extraConfig = LT.nginx.locationAutoindexConf;
        "/cgi-bin/" = {
          index = "index.sh";
          extraConfig = LT.nginx.locationFcgiwrapConf;
        };
        "/glibc-for-debian-10-on-openvz".extraConfig = LT.nginx.locationAutoindexConf;
        "/hobby-net".extraConfig = LT.nginx.locationAutoindexConf;
        "/zjui-ece385-scoreboard".extraConfig = ''
          gzip off;
          brotli off;
          zstd off;
        '';
      };
    extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };

  services.phpfpm.pools.lab = {
    phpPackage = pkgs.phpWithExtensions;
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

  services.fcgiwrap = {
    enable = true;
    inherit (config.services.nginx) user group;
  };

  systemd.services.fcgiwrap.serviceConfig = LT.serviceHarden // {
    ReadWritePaths = [
      "/var/www/lab.lantian.pub"
    ];
  };

  systemd.tmpfiles.rules = let
    dngzwxdq = compressStaticAssets (pkgs.callPackage pkgs/dngzwxdq.nix { });
    dnyjzsxj = compressStaticAssets (pkgs.callPackage pkgs/dnyjzsxj.nix { });
    glibc-debian-openvz-files = pkgs.callPackage pkgs/glibc-debian-openvz-files.nix { };
    mota-24 = compressStaticAssets (pkgs.callPackage pkgs/mota-24.nix { });
    mota-51 = compressStaticAssets (pkgs.callPackage pkgs/mota-51.nix { });
    mota-xinxin = compressStaticAssets (pkgs.callPackage pkgs/mota-xinxin.nix { });

  in [
    "L+ ${labRoot}/dngzwxdq - - - - ${dngzwxdq}"
    "L+ ${labRoot}/dnyjzsxj - - - - ${dnyjzsxj}"
    "L+ ${labRoot}/glibc-for-debian-10-on-openvz - - - - ${glibc-debian-openvz-files}"
    "L+ ${labRoot}/hobby-net - - - - /nix/persistent/sync-servers/ltnet-scripts"
    "L+ ${labRoot}/mota-24 - - - - ${mota-24}"
    "L+ ${labRoot}/mota-51 - - - - ${mota-51}"
    "L+ ${labRoot}/mota-xinxin - - - - ${mota-xinxin}"
    "L+ ${labRoot}/testssl.html - - - - /nix/persistent/sync-servers/www/lab.lantian.pub/testssl.htm"
  ];
}
