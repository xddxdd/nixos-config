{ lib, ... }:
let
  mkTestSSL =
    name:
    lib.nameValuePair "${name}.lantian.pub" {
      root = "/nix/persistent/sync-servers/www/${name}.lantian.pub";
      locations."/".index = "testssl.htm";
      sslCertificate = "lets-encrypt-${name}.lantian.pub";
      enableCommonLocationOptions = false;
    };
in
# Temporarily disabled during certificate migration
lib.mkIf false {
  lantian.nginxVhosts = builtins.listToAttrs (
    builtins.map mkTestSSL [
      "buypass-ssl"
      "google-ssl"
      "google-test-ssl"
      "letsencrypt-ssl"
      "letsencrypt-test-ssl"
      "zerossl"
    ]
  );
}
