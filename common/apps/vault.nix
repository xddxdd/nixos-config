{ config, pkgs, ... }:

let
  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };
in
{
  services.vault = {
    enable = true;
    package = pkgs.vault-bin;
    address = "127.0.0.1:8200";
    storageBackend = "file";
    storagePath = "/var/lib/vault";
    extraConfig = ''
      ui = 1
    '';
  };

  services.nginx.virtualHosts = {
    "vault.lantian.pub" = {
      listen = nginxHelper.listen443;
      locations = nginxHelper.addCommonLocationConf {
        "/" = {
          proxyPass = "http://127.0.0.1:8200";
          extraConfig = nginxHelper.locationProxyConf;
        };
      };
      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.commonVhostConf true;
    };
  };
}
