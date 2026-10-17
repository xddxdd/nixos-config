_:
let
  rsaRenewInterval = "*-*-* 01:00:00";
  eccRenewInterval = "*-*-* 13:00:00";
in
{
  # # For temporarily setting one time use EAB credentials:
  # environmentFile = [
  #   config.sops.secrets.lego-env.path
  #   (pkgs.writeText "env" ''
  #     LEGO_EAB_KID=123456
  #     LEGO_EAB_HMAC=abcdef
  #   '')
  # ];

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
