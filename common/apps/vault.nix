{ config, pkgs, ... }:

let
  LT = import ../helpers.nix {  inherit config pkgs; };
in
{
  services.vault = {
    enable = true;
    package = pkgs.vault-bin;
    address = "127.0.0.1:${LT.portStr.Vault}";
    storageBackend = "file";
    storagePath = "/var/lib/vault";
    extraConfig = ''
      ui = 1
    '';
  };

  services.nginx.virtualHosts = {
    "vault.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Vault}";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true;
    };
  };
}
