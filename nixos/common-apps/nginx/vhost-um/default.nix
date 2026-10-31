{
  pkgs,
  lib,
  LT,
  ...
}:
let
  um = LT.nginx.compressStaticAssets (pkgs.callPackage ./um.nix { inherit (LT) sources; });
in
lib.mkIf (LT.this.hasTag LT.tags.public-facing) {
  lantian.nginxVhosts."um.xuyh0120.win" = {
    root = um;
    accessibleBy = "private";
    sslCertificate = "lets-encrypt-xuyh0120.win";
    noIndex.enable = true;
    disableLiveCompression = true;
  };
}
