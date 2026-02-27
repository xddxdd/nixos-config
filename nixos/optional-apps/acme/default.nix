{
  inputs,
  config,
  lib,
  pkgs,
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
    maxConcurrentRenewals = 0;

    defaults = {
      dnsProvider = "gcore";
      dnsResolver = "8.8.8.8:53";
      dnsPropagationCheck = false;
      email = glauthUsers.lantian.mail;
      environmentFile = [ config.age.secrets.lego-env.path ];
      postRun = ''
        CERT=$(basename $(pwd))
        install -Dm644 --owner=root -t /nix/sync-servers/acme/"$CERT" *
      '';
    };
  };

  systemd.services = {
    acme-check-expiration = {
      serviceConfig.Type = "oneshot";
      path = [ pkgs.openssl ];
      script = ''
        ERRORS=0
        for F in /var/lib/acme/*/cert.pem; do
          echo "$F"
          # Check for 10 days of validity
          if openssl x509 -checkend 172800 -noout -in "$F"; then
            ERRORS=$((ERRORS + 0))
          else
            ERRORS=$((ERRORS + 1))
          fi
        done
        echo "Total $ERRORS errors"
        exit $ERRORS
      '';
      unitConfig.OnFailure = "notify-email@%n.service";
    };
  }
  // lib.mapAttrs' (
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

  systemd.timers.acme-check-expiration = {
    wantedBy = [ "timers.target" ];
    partOf = [ "acme-check-expiration.service" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "acme-check-expiration.service";
    };
  };
}
