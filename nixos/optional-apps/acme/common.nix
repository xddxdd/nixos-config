_:
let
  rsaRenewInterval = "*-*-* 01:00:00";
  eccRenewInterval = "*-*-* 13:00:00";
in
{
  # # For temporarily setting one time use EAB credentials:
  # environmentFile = [
  #   config.age.secrets.lego-env.path
  #   (pkgs.writeText "env" ''
  #     LEGO_EAB_KID=123456
  #     LEGO_EAB_HMAC=abcdef
  #   '')
  # ];

  mkLetsEncryptCert = domain: {
    "lets-encrypt-${domain}-rsa" = {
      inherit domain;
      extraLegoRunFlags = [ "--profile=shortlived" ];
      extraLegoRenewFlags = [ "--profile=shortlived" ];
      keyType = "rsa4096";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = rsaRenewInterval;
    };
    "lets-encrypt-${domain}-ecc" = {
      inherit domain;
      extraLegoRunFlags = [ "--profile=shortlived" ];
      extraLegoRenewFlags = [ "--profile=shortlived" ];
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
      extraLegoRunFlags = [ "--profile=shortlived" ];
      extraLegoRenewFlags = [ "--profile=shortlived" ];
      keyType = "rsa4096";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = rsaRenewInterval;
    };
    "lets-encrypt-${domain}-ecc" = {
      inherit domain;
      extraDomainNames = [ "*.${domain}" ];
      extraLegoRunFlags = [ "--profile=shortlived" ];
      extraLegoRenewFlags = [ "--profile=shortlived" ];
      keyType = "ec384";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = eccRenewInterval;
    };
  };

  mkLetsEncryptTestCert = domain: {
    "lets-encrypt-test-${domain}-rsa" = {
      inherit domain;
      extraLegoRunFlags = [ "--profile=shortlived" ];
      extraLegoRenewFlags = [ "--profile=shortlived" ];
      keyType = "rsa4096";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = rsaRenewInterval;
    };
    "lets-encrypt-test-${domain}-ecc" = {
      inherit domain;
      extraLegoRunFlags = [ "--profile=shortlived" ];
      extraLegoRenewFlags = [ "--profile=shortlived" ];
      keyType = "ec384";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      validMinDays = 3;
      renewInterval = eccRenewInterval;
    };
  };

  mkGoogleCert = domain: {
    "google-${domain}-rsa" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "rsa4096";
      server = "https://dv.acme-v02.api.pki.goog/directory";
      validMinDays = 30;
      renewInterval = rsaRenewInterval;
    };
    "google-${domain}-ecc" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "ec384";
      server = "https://dv.acme-v02.api.pki.goog/directory";
      validMinDays = 30;
      renewInterval = eccRenewInterval;
    };
  };

  mkGoogleTestCert = domain: {
    "google-test-${domain}-rsa" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "rsa4096";
      server = "https://dv.acme-v02.test-api.pki.goog/directory";
      validMinDays = 30;
      renewInterval = rsaRenewInterval;
    };
    "google-test-${domain}-ecc" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "ec384";
      server = "https://dv.acme-v02.test-api.pki.goog/directory";
      validMinDays = 30;
      renewInterval = eccRenewInterval;
    };
  };

  mkZeroSSLCert = domain: {
    "zerossl-${domain}-rsa" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "rsa4096";
      server = "https://acme.zerossl.com/v2/DV90";
      validMinDays = 30;
      renewInterval = rsaRenewInterval;
    };
    "zerossl-${domain}-ecc" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "ec384";
      server = "https://acme.zerossl.com/v2/DV90";
      validMinDays = 30;
      renewInterval = eccRenewInterval;
    };
  };

  mkZeroSSLWildcardCert = domain: {
    "zerossl-${domain}-rsa" = {
      inherit domain;
      extraDomainNames = [ "*.${domain}" ];
      extraLegoFlags = [ "--eab" ];
      keyType = "rsa4096";
      server = "https://acme.zerossl.com/v2/DV90";
      validMinDays = 30;
      renewInterval = rsaRenewInterval;
    };
    "zerossl-${domain}-ecc" = {
      inherit domain;
      extraDomainNames = [ "*.${domain}" ];
      extraLegoFlags = [ "--eab" ];
      keyType = "ec384";
      server = "https://acme.zerossl.com/v2/DV90";
      validMinDays = 30;
      renewInterval = eccRenewInterval;
    };
  };
}
