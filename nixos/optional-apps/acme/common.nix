_:
let
  rsaRenewInterval = "*-*-* 01:00:00";
  eccRenewInterval = "*-*-* 13:00:00";
in
{
  mkLetsEncryptCert = domain: {
    "lets-encrypt-${domain}-rsa" = {
      inherit domain;
      extraLegoFlags = [ "--dns.propagation.wait=60s" ];
      keyType = "rsa4096";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = rsaRenewInterval;
    };
    "lets-encrypt-${domain}-ecc" = {
      inherit domain;
      extraLegoFlags = [ "--dns.propagation.wait=60s" ];
      keyType = "ec384";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = eccRenewInterval;
    };
  };

  mkLetsEncryptWildcardCert = domain: {
    "lets-encrypt-${domain}-rsa" = {
      inherit domain;
      extraDomainNames = [ "*.${domain}" ];
      extraLegoFlags = [ "--dns.propagation.wait=60s" ];
      keyType = "rsa4096";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = rsaRenewInterval;
    };
    "lets-encrypt-${domain}-ecc" = {
      inherit domain;
      extraDomainNames = [ "*.${domain}" ];
      extraLegoFlags = [ "--dns.propagation.wait=60s" ];
      keyType = "ec384";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = eccRenewInterval;
    };
  };

  mkLetsEncryptTestCert = domain: {
    "lets-encrypt-test-${domain}-rsa" = {
      inherit domain;
      extraLegoFlags = [ "--dns.propagation.wait=60s" ];
      keyType = "rsa4096";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = rsaRenewInterval;
    };
    "lets-encrypt-test-${domain}-ecc" = {
      inherit domain;
      extraLegoFlags = [ "--dns.propagation.wait=60s" ];
      keyType = "ec384";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = eccRenewInterval;
    };
  };
}
