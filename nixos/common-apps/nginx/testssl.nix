{ lib, ... }:
let
  mkTestSSL =
    pair:
    let
      name = builtins.elemAt pair 0;
      prefix = builtins.elemAt pair 1;
    in
    lib.nameValuePair "${name}.lantian.pub" {
      root = "/nix/persistent/sync-servers/www/${name}.lantian.pub";
      locations."/".index = "testssl.htm";
      sslCertificate = "${prefix}-${name}.lantian.pub";
      enableCommonLocationOptions = false;
    };
in
{
  lantian.nginxVhosts = builtins.listToAttrs (
    builtins.map mkTestSSL [
      [
        "buypass-ssl"
        "buypass"
      ]
      [
        "buypass-test-ssl"
        "buypass-test"
      ]
      [
        "google-ssl"
        "google"
      ]
      [
        "google-test-ssl"
        "google-test"
      ]
      [
        "letsencrypt-ssl"
        "lets-encrypt"
      ]
      [
        "letsencrypt-test-ssl"
        "lets-encrypt-test"
      ]
      [
        "zerossl"
        "zerossl"
      ]
    ]
  );
}
