{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  age.secrets.vault-unseal-key = {
    file = inputs.secrets + "/vault-unseal-key.age";
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
        exec ${config.services.vault.package}/bin/vault operator unseal \
          -address=http://${config.services.vault.address} \
          $(cat ${config.age.secrets.vault-unseal-key.path})
      '';
    in
    "${script}";

  services.nginx.virtualHosts = {
    "vault.xuyh0120.win" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf { } {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.Vault}";
          extraConfig = LT.nginx.locationProxyConf;
        };
      };
      extraConfig = LT.nginx.makeSSL "xuyh0120.win_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
  };
}
