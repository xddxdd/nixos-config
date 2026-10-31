{ pkgs, ... }:
rec {
  getSSLPath = acmeName: "/nix/sync-servers/acme/${acmeName}";
  getSSLCert = acmeName: "${getSSLPath acmeName}/fullchain.pem";
  getSSLKey = acmeName: "${getSSLPath acmeName}/key.pem";

  compressStaticAssets =
    p:
    p.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.web-compressor ];

      postFixup = (old.postFixup or "") + ''
        web-compressor --target $out
      '';
    });
}
