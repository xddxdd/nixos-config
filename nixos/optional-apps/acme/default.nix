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
      dnsProvider = "gcore";
      dnsResolver = "8.8.8.8:53";
      dnsPropagationCheck = false;
      email = glauthUsers.lantian.mail;
      environmentFile = [ config.sops.secrets.lego-env.path ];
      postRun = ''
        CERT=$(basename $(pwd))
        install -Dm644 --owner=root -t /nix/sync-servers/acme/"$CERT" *
      '';
    };
  };

  systemd.services = lib.mapAttrs' (
    k: v:
    lib.nameValuePair "acme-${k}" {
      environment = {
        LEGO_DEBUG_CLIENT_VERBOSE_ERROR = "true";
        LEGO_DEBUG_ACME_HTTP_CLIENT = "true";
      };
      serviceConfig = {
        Restart = "on-failure";
        TimeoutStartSec = "900";
      };
    }
  ) config.security.acme.certs;
}
