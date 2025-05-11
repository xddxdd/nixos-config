{ pkgs, lib, ... }:
rec {
  getSSLPath = acmeName: "/nix/persistent/sync-servers/acme.sh/${acmeName}";
  getSSLCert = acmeName: "${getSSLPath acmeName}/fullchain.cer";
  getSSLKey = acmeName: "${getSSLPath acmeName}/${builtins.head (lib.splitString "_" acmeName)}.key";

  compressStaticAssets = p: pkgs.compressDrvWeb p { };
}
