{
  pkgs,
  lib,
  LT,
  ...
}:
let
  tools = {
    cyberchef = (LT.nginx.compressStaticAssets pkgs.cyberchef) + "/share/cyberchef";
    dngzwxdq = LT.nginx.compressStaticAssets (pkgs.callPackage ./dngzwxdq.nix { });
    dnyjzsxj = LT.nginx.compressStaticAssets (pkgs.callPackage ./dnyjzsxj.nix { });
    glibc-debian-openvz-files = pkgs.callPackage ./glibc-debian-openvz-files.nix { };
    # # Upstream unavailable
    # um = LT.nginx.compressStaticAssets (pkgs.callPackage ./um.nix { inherit (LT) sources; });
  };
in
lib.mkIf (!(LT.this.hasTag LT.tags.low-disk)) {
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
    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
    blockAIBots = true;
    disableLiveCompression = true;
  };
}
