{ lib, ... }:
let
  mkTestSSL =
    name:
    lib.nameValuePair "${name}.lantian.pub" {
      root = "/nix/persistent/sync-servers/www/${name}.lantian.pub";
      locations."/".index = "testssl.htm";
      sslCertificate = "${name}.lantian.pub";
      enableCommonLocationOptions = false;
    };
in
{
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
