{
  inputs,
  config,
  lib,
  ...
}:
let
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");
in
{
  imports = [
    ./base-domains.nix
    ./cert-exporter.nix
    ./testssl.nix
  ];

  sops.secrets.lego-env = {
    sopsFile = inputs.secrets + "/lego.yaml";
    owner = "acme";
    group = "acme";
  };

  security.acme = {
    acceptTerms = true;
    maxConcurrentRenewals = 0;

    defaults = {
      dnsProvider = "bunny";
      dnsResolver = "8.8.8.8:53";
      dnsPropagationCheck = true;
      email = glauthUsers.lantian.mail;
      environmentFile = [ config.sops.secrets.lego-env.path ];
      postRun = ''
        CERT=$(basename $(pwd))
        install -Dm644 --owner=root -t /nix/sync-servers/acme/"$CERT" *
      '';
    };
  };

  systemd.services =
    let
      cfg = {
        serviceConfig = {
          Restart = "on-failure";
          TimeoutStartSec = "900";
        };
      };

      # Renewal jobs of the same domain (RSA/ECC, ZeroSSL/Let's Encrypt)
      # exclude each other, so at most one runs at a time.
      certsByDomain = lib.groupBy (name: config.security.acme.certs.${name}.domain) (
        builtins.attrNames config.security.acme.certs
      );

      orderRenewCfg =
        name: conf:
        cfg
        // {
          conflicts = map (other: "acme-order-renew-${other}.service") (
            builtins.filter (other: other != name) certsByDomain.${conf.domain}
          );
        };
    in
    (lib.mapAttrs' (k: v: lib.nameValuePair "acme-${k}" cfg) config.security.acme.certs)
    // (lib.mapAttrs' (
      k: v: lib.nameValuePair "acme-order-renew-${k}" (orderRenewCfg k v)
    ) config.security.acme.certs);
}
