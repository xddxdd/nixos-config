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
    ./testssl.nix
  ];

  age.secrets.lego-env = {
    file = inputs.secrets + "/lego-env.age";
    owner = "acme";
    group = "acme";
  };

  security.acme = {
    acceptTerms = true;
    preliminarySelfsigned = false;
    maxConcurrentRenewals = 2;

    defaults = {
      dnsProvider = "gcore";
      dnsResolver = "8.8.8.8:53";
      email = glauthUsers.lantian.mail;
      environmentFile = [ config.age.secrets.lego-env.path ];
      postRun = ''
        CERT=$(basename $(pwd))
        install -Dm644 --owner=root -t /nix/persistent/sync-servers/acme/"$CERT" *
      '';
    };
  };

  # Send email notification if cert renew failed
  systemd.services = lib.mapAttrs' (
    k: _v:
    lib.nameValuePair "acme-${k}" {
      unitConfig.OnFailure = "notify-email-fail@%n.service";
    }
  ) config.security.acme.certs;
}
