{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;

  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };

  addConfLantianPub = pkgs.lib.recursiveUpdate {
    locations = nginxHelper.addCommonLocationConf {
      "/" = {
        index = "index.html index.htm";
      };
      "/assets/".extraConfig = ''
        expires 31536000;
      '';
      "/usr/" = {
        tryFiles = "$uri$avif_suffix$webp_suffix $uri$avif_suffix $uri$webp_suffix $uri =404";
        extraConfig = ''
          expires 31536000;
          add_header Vary "Accept";
          add_header Cache-Control "public, no-transform";
        '';
      };
      "= /favicon.ico".extraConfig = ''
        expires 31536000;
      '';
      "/feed".tryFiles = "$uri /feed.xml /atom.xml =404";
    };

    root = "/var/www/lantian.pub";
  };
in
{
  services.nginx.virtualHosts = {
    "localhost" = {
      listen = [
        { addr = "0.0.0.0"; port = 443; extraParameters = [ "ssl" "http2" ] ++ nginxHelper.listenDefaultFlags; }
        { addr = "[::]"; port = 443; extraParameters = [ "ssl" "http2" ] ++ nginxHelper.listenDefaultFlags; }
        { addr = "0.0.0.0"; port = 443; extraParameters = [ "default_server" "http3" "reuseport" ]; }
        { addr = "[::]"; port = 443; extraParameters = [ "default_server" "http3" "reuseport" ]; }
        { addr = "0.0.0.0"; port = 80; extraParameters = nginxHelper.listenDefaultFlags; }
        { addr = "[::]"; port = 80; extraParameters = nginxHelper.listenDefaultFlags; }
      ];

      locations = {
        "/".return = "444";
        "= /.well-known/openid-configuration".extraConfig = ''
          root ${../files/openid-configuration};
          try_files /openid-configuration =404;
        '';
        "= /openid-configuration".extraConfig = ''
          root ${../files/openid-configuration};
          try_files /openid-configuration =404;
        '';
        "/generate_204".return = "204";
      };

      rejectSSL = true;

      extraConfig = ''
        access_log off;
        ssl_stapling off;
      '';
    };

    "lantian.pub" = addConfLantianPub {
      listen = nginxHelper.listen443 ++ nginxHelper.listen80;
      serverAliases = pkgs.lib.mapAttrsToList (k: v: k + ".lantian.pub") hosts;
      extraConfig = ''
        gzip off;
        gzip_static on;
        brotli off;
        brotli_static on;

        error_page 404 /404.html;
      ''
      + nginxHelper.makeSSL "lantian.pub_ecc"
      + nginxHelper.commonVhostConf true;
    };
    "lantian.dn42" = addConfLantianPub {
      listen = nginxHelper.listen443 ++ nginxHelper.listen80;
      extraConfig = ''
        gzip off;
        gzip_static on;
        brotli off;
        brotli_static on;

        error_page 404 /404.html;
      ''
      + nginxHelper.makeSSL "lantian.dn42_ecc"
      + nginxHelper.commonVhostConf false;
    };
    "lantian.neo" = addConfLantianPub {
      listen = nginxHelper.listen80;
      extraConfig = ''
        gzip off;
        gzip_static on;
        brotli off;
        brotli_static on;

        error_page 404 /404.html;
      ''
      + nginxHelper.commonVhostConf false;
    };

    "www.lantian.pub" = {
      listen = nginxHelper.listen443 ++ nginxHelper.listen80;
      globalRedirect = "lantian.pub";
      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.commonVhostConf true;
    };
    "xuyh0120.win" = {
      listen = nginxHelper.listen443 ++ nginxHelper.listen80;
      serverAliases = [ "www.xuyh0120.win" ];
      globalRedirect = "lantian.pub";
      extraConfig = nginxHelper.makeSSL "xuyh0120.win_ecc"
        + nginxHelper.commonVhostConf true;
    };
    "lab.xuyh0120.win" = {
      listen = nginxHelper.listen443 ++ nginxHelper.listen80;
      globalRedirect = "lab.lantian.pub";
      extraConfig = nginxHelper.makeSSL "xuyh0120.win_ecc"
        + nginxHelper.commonVhostConf true;
    };

    "gopher.lantian.pub" = {
      listen = nginxHelper.listen443
        ++ nginxHelper.listen80
        ++ nginxHelper.listenPlain 70
        ++ nginxHelper.listenPlainProxyProtocol 13270;
      root = "/var/www/lantian.pub";
      serverAliases = [ "gopher.lantian.dn42" "gopher.lantian.neo" ];

      locations."/" = {
        index = "gophermap";
        extraConfig = ''
          sub_filter "{{server_addr}}\t{{server_port}}" "$gopher_addr\t$server_port";
          sub_filter_once off;
          sub_filter_types '*';
        '';
      };

      extraConfig = ''
        error_page 404 /404.gopher;
      ''
      + nginxHelper.makeSSL "lantian.pub_ecc"
      + nginxHelper.commonVhostConf true
      + nginxHelper.listenProxyProtocol
      + nginxHelper.noIndex;
    };

    "lab.lantian.pub" = pkgs.lib.mkIf (config.lantian.enable-lab) {
      listen = nginxHelper.listen443;
      root = "/var/www/lab.lantian.pub";
      locations = nginxHelper.addCommonLocationConf {
        "/" = {
          index = "index.php index.html index.htm";
          tryFiles = "$uri $uri/ =404";
        };
        "= /".extraConfig = ''
          autoindex on;
          add_after_body /autoindex.html;
        '';
        "/hobby-net".extraConfig = ''
          autoindex on;
          add_after_body /autoindex.html;
        '';
        "/zjui-ece385-scoreboard".extraConfig = ''
          gzip off;
          brotli off;
          zstd off;
        '';
      };
      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.commonVhostConf true
        + nginxHelper.noIndex;
    };
  };
}
