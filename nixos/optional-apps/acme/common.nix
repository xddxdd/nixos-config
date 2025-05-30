_: {
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
      extraLegoRunFlags = [ "--profile=tlsserver" ];
      extraLegoRenewFlags = [ "--profile=tlsserver" ];
      keyType = "rsa4096";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 30;
    };
    "lets-encrypt-${domain}-ecc" = {
      inherit domain;
      extraLegoRunFlags = [ "--profile=tlsserver" ];
      extraLegoRenewFlags = [ "--profile=tlsserver" ];
      keyType = "ec384";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      validMinDays = 30;
    };
  };

  mkLetsEncryptWildcardCert = domain: {
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

  mkLetsEncryptTestCert = domain: {
    "lets-encrypt-test-${domain}-rsa" = {
      inherit domain;
      extraLegoRunFlags = [ "--profile=tlsserver" ];
      extraLegoRenewFlags = [ "--profile=tlsserver" ];
      keyType = "rsa4096";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      validMinDays = 30;
    };
    "lets-encrypt-test-${domain}-ecc" = {
      inherit domain;
      extraLegoRunFlags = [ "--profile=tlsserver" ];
      extraLegoRenewFlags = [ "--profile=tlsserver" ];
      keyType = "ec384";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      validMinDays = 30;
    };
  };

  mkBuyPassCert = domain: {
    "buypass-${domain}-rsa" = {
      inherit domain;
      keyType = "rsa4096";
      server = "https://api.buypass.com/acme/directory";
      validMinDays = 30;
    };
    "buypass-${domain}-ecc" = {
      inherit domain;
      keyType = "ec256";
      server = "https://api.buypass.com/acme/directory";
      validMinDays = 30;
    };
  };

  mkBuyPassTestCert = domain: {
    "buypass-test-${domain}-rsa" = {
      inherit domain;
      keyType = "rsa4096";
      server = "https://api.test4.buypass.no/acme/directory";
      validMinDays = 30;
    };
    "buypass-test-${domain}-ecc" = {
      inherit domain;
      keyType = "ec256";
      server = "https://api.test4.buypass.no/acme/directory";
      validMinDays = 30;
    };
  };

  mkGoogleCert = domain: {
    "google-${domain}-rsa" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "rsa4096";
      server = "https://dv.acme-v02.api.pki.goog/directory";
      validMinDays = 30;
    };
    "google-${domain}-ecc" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "ec384";
      server = "https://dv.acme-v02.api.pki.goog/directory";
      validMinDays = 30;
    };
  };

  mkGoogleTestCert = domain: {
    "google-test-${domain}-rsa" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "rsa4096";
      server = "https://dv.acme-v02.test-api.pki.goog/directory";
      validMinDays = 30;
    };
    "google-test-${domain}-ecc" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "ec384";
      server = "https://dv.acme-v02.test-api.pki.goog/directory";
      validMinDays = 30;
    };
  };

  mkZeroSSLCert = domain: {
    "zerossl-${domain}-rsa" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "rsa4096";
      server = "https://acme.zerossl.com/v2/DV90";
      validMinDays = 30;
    };
    "zerossl-${domain}-ecc" = {
      inherit domain;
      extraLegoFlags = [ "--eab" ];
      keyType = "ec384";
      server = "https://acme.zerossl.com/v2/DV90";
      validMinDays = 30;
    };
  };
}
