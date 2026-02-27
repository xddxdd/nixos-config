{ pkgs, ... }:
rec {
  getSSLPath = acmeName: "/nix/sync-servers/acme/${acmeName}";
  getSSLCert = acmeName: "${getSSLPath acmeName}/fullchain.pem";
  getSSLKey = acmeName: "${getSSLPath acmeName}/key.pem";

  compressStaticAssets = p: pkgs.compressDrvWeb p { };
}
