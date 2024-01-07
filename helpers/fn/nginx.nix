{
  config,
  pkgs,
  lib,
  hosts,
  this,
  port,
  portStr,
  inputs,
  constants,
  ...
}: rec {
  getSSLPath = acmeName: "/nix/persistent/sync-servers/acme.sh/${acmeName}";
  getSSLCert = acmeName: "${getSSLPath acmeName}/fullchain.cer";
  getSSLKey = acmeName: "${getSSLPath acmeName}/${builtins.head (lib.splitString "_" acmeName)}.key";

  compressStaticAssets = p:
    p.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.web-compressor];

      postFixup =
        (old.postFixup or "")
        + ''
          web-compressor --target $out
        '';
    });
}
