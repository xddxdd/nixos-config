{ pkgs, ... }:
rec {
  getSSLPath = acmeName: "/nix/persistent/sync-servers/acme/${acmeName}";
  getSSLCert = acmeName: "${getSSLPath acmeName}/fullchain.pem";
  getSSLKey = acmeName: "${getSSLPath acmeName}/key.pem";

  compressStaticAssets = p: pkgs.compressDrvWeb p { };
}
