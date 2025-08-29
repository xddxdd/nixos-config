{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage ./common.nix { inherit config; })
    mkGoogleCert
    mkGoogleTestCert
    mkLetsEncryptCert
    mkLetsEncryptTestCert
    mkZeroSSLCert
    ;
in
{
  security.acme.certs = lib.mergeAttrsList [
    (mkGoogleCert "google-ssl.lantian.pub")
    (mkGoogleTestCert "google-test-ssl.lantian.pub")
    (mkLetsEncryptCert "letsencrypt-ssl.lantian.pub")
    (mkLetsEncryptTestCert "letsencrypt-test-ssl.lantian.pub")
    (mkZeroSSLCert "zerossl.lantian.pub")
  ];
}
