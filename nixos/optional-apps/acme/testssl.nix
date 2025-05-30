{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage ./common.nix { inherit config; })
    mkBuyPassCert
    mkBuyPassTestCert
    mkGoogleCert
    mkGoogleTestCert
    mkLetsEncryptCert
    mkLetsEncryptTestCert
    mkZeroSSLCert
    ;
in
{
  security.acme.certs = lib.mergeAttrsList [
    (mkBuyPassCert "buypass-ssl.lantian.pub")
    (mkBuyPassTestCert "buypass-test-ssl.lantian.pub")
    (mkGoogleCert "google-ssl.lantian.pub")
    (mkGoogleTestCert "google-test-ssl.lantian.pub")
    (mkLetsEncryptCert "letsencrypt-ssl.lantian.pub")
    (mkLetsEncryptTestCert "letsencrypt-test-ssl.lantian.pub")
    (mkZeroSSLCert "zerossl.lantian.pub")
  ];
}
