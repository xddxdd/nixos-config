{
  pkgs,
  lib,
  LT,
  ...
}:
let
  tools = {
    cyberchef =
      (LT.nginx.compressStaticAssets (
        pkgs.cyberchef.overrideAttrs (old: {
          postFixup = ''
            find $out/ -name \*.gz -delete
            find $out/ -name \*.br -delete
          '';
        })
      ))
      + "/share/cyberchef";
    dngzwxdq = LT.nginx.compressStaticAssets (pkgs.callPackage ./dngzwxdq.nix { });
    dnyjzsxj = LT.nginx.compressStaticAssets (pkgs.callPackage ./dnyjzsxj.nix { });
    glibc-debian-openvz-files = pkgs.callPackage ./glibc-debian-openvz-files.nix { };
  };
in
lib.mkIf (!(LT.this.hasTag LT.tags.low-disk)) {
  lantian.nginxVhosts."tools.lantian.pub" = {
    root = pkgs.linkFarm "tools" tools;
    locations = {
      "/" = {
        enableAutoIndex = true;
        index = "index.php index.html index.htm";
        tryFiles = "$uri $uri/ =404";
      };
    };
    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
    disableLiveCompression = true;
  };
}
