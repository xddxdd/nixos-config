{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  mkTestSSL = name:
    lib.nameValuePair "${name}.lantian.pub" {
      listen = LT.nginx.listenHTTPS;
      root = "/nix/persistent/sync-servers/www/${name}.lantian.pub";
      locations."/".index = "testssl.htm";
      extraConfig =
        LT.nginx.makeSSL "${name}.lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
in {
  services.nginx.virtualHosts = builtins.listToAttrs (builtins.map mkTestSSL [
    "buypass-ssl"
    "google-ssl"
    "google-test-ssl"
    "letsencrypt-ssl"
    "letsencrypt-test-ssl"
    "zerossl"
  ]);
}
