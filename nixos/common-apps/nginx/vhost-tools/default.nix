{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  tools = {
    cyberchef = LT.nginx.compressStaticAssets (
      pkgs.callPackage ./cyberchef.nix { inherit (LT) sources; }
    );
    dngzwxdq = LT.nginx.compressStaticAssets (pkgs.callPackage ./dngzwxdq.nix { });
    dnyjzsxj = LT.nginx.compressStaticAssets (pkgs.callPackage ./dnyjzsxj.nix { });
    glibc-debian-openvz-files = pkgs.callPackage ./glibc-debian-openvz-files.nix { };
    mota-24 = LT.nginx.compressStaticAssets (pkgs.callPackage ./mota-24.nix { });
    mota-51 = LT.nginx.compressStaticAssets (pkgs.callPackage ./mota-51.nix { });
    mota-xinxin = LT.nginx.compressStaticAssets (pkgs.callPackage ./mota-xinxin.nix { });
  };
in
lib.mkIf (!(builtins.elem LT.tags.low-disk LT.this.tags)) {
  networking.hosts."127.0.0.1" = [ "tools.lantian.pub" ];

  lantian.nginxVhosts."tools.lantian.pub" = {
    root = pkgs.linkFarm "tools" tools;
    locations = {
      "/" = {
        enableAutoIndex = true;
        index = "index.php index.html index.htm";
        tryFiles = "$uri $uri/ =404";
      };
    };
    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
    extraConfig = ''
      gzip off;
      gzip_static on;
      brotli off;
      brotli_static on;
      zstd off;
      zstd_static on;
    '';
  };
}
