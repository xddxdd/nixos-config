{
  inputs,
  config,
  LT,
  lib,
  ...
}:
let
  glauthUsers = import (inputs.secrets + "/glauth-users.nix");
  hostSubdomains = lib.mapAttrsToList (n: _v: "${n}.xuyh0120.win") LT.hosts;

  mkLetsEncryptCert = domain: {
    "lets-encrypt-${domain}-rsa" = {
      inherit domain;
      extraDomainNames = [ "*.${domain}" ];
      extraLegoRunFlags = [ "--profile=tlsserver" ];
      extraLegoRenewFlags = [ "--profile=tlsserver" ];
      keyType = "rsa4096";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 30;
    };
    "lets-encrypt-${domain}-ecc" = {
      inherit domain;
      extraDomainNames = [ "*.${domain}" ];
      extraLegoRunFlags = [ "--profile=tlsserver" ];
      extraLegoRenewFlags = [ "--profile=tlsserver" ];
      keyType = "ec384";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 30;
    };
  };
in
{
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
      environmentFile = config.age.secrets.lego-env.path;
      postRun = ''
        CERT=$(basename $(pwd))
        install -Dm644 --owner=root -t /nix/persistent/sync-servers/acme/"$CERT" *
      '';
    };

    certs = lib.mergeAttrsList (
      [
        (mkLetsEncryptCert "lantian.pub")
        (mkLetsEncryptCert "xuyh0120.win")
        (mkLetsEncryptCert "56631131.xyz")
        (mkLetsEncryptCert "ltn.pw")
      ]
      ++ (builtins.map mkLetsEncryptCert hostSubdomains)
    );
  };

  # Send email notification if cert renew failed
  systemd.services = lib.mapAttrs' (
    k: _v:
    lib.nameValuePair "acme-${k}" {
      unitConfig.OnFailure = "notify-email-fail@%n.service";
    }
  ) config.security.acme.certs;
}
