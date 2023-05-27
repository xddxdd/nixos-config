{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  tools = {
    cyberchef = LT.nginx.compressStaticAssets (pkgs.callPackage ./cyberchef.nix {inherit (LT) sources;});
    dngzwxdq = LT.nginx.compressStaticAssets (pkgs.callPackage ./dngzwxdq.nix {});
    dnyjzsxj = LT.nginx.compressStaticAssets (pkgs.callPackage ./dnyjzsxj.nix {});
    glibc-debian-openvz-files = pkgs.callPackage ./glibc-debian-openvz-files.nix {};
    mota-24 = LT.nginx.compressStaticAssets (pkgs.callPackage ./mota-24.nix {});
    mota-51 = LT.nginx.compressStaticAssets (pkgs.callPackage ./mota-51.nix {});
    mota-xinxin = LT.nginx.compressStaticAssets (pkgs.callPackage ./mota-xinxin.nix {});
  };
in {
  services.nginx.virtualHosts."tools.lantian.pub" = {
    listen = LT.nginx.listenHTTPS;
    root = pkgs.linkFarm "tools" tools;
    locations = LT.nginx.addCommonLocationConf {} {
      "/" = {
        index = "index.php index.html index.htm";
        tryFiles = "$uri $uri/ =404";
        extraConfig = LT.nginx.locationAutoindexConf;
      };
    };
    extraConfig =
      LT.nginx.makeSSL "lantian.pub_ecc"
      + LT.nginx.commonVhostConf true
      + LT.nginx.noIndex true;
  };
}
