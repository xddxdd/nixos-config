{
  pkgs,
  LT,
  ...
}:
let
  um = LT.nginx.compressStaticAssets (pkgs.callPackage ./um.nix { inherit (LT) sources; });
in
{
  lantian.nginxVhosts."um.xuyh0120.win" = {
    root = um;
    accessibleBy = "private";
    sslCertificate = "zerossl-xuyh0120.win";
    noIndex.enable = true;
    disableLiveCompression = true;
  };
}
