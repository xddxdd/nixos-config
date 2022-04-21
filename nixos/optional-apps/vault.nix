{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  age.secrets.vault-unseal-key = {
    file = pkgs.secrets + "/vault-unseal-key.age";
    owner = config.systemd.services.vault.serviceConfig.User;
    group = config.systemd.services.vault.serviceConfig.Group;
  };

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

  systemd.services.vault.serviceConfig.ExecStartPost =
    let
      script = pkgs.writeShellScript "vault-unseal" ''
        sleep 10
        ${config.services.vault.package}/bin/vault operator unseal \
          -address=http://${config.services.vault.address} \
          $(cat ${config.age.secrets.vault-unseal-key.path})
      '';
    in
    "${script}";

  services.nginx.virtualHosts = {
    "vault.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { noindex = true; } {
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
