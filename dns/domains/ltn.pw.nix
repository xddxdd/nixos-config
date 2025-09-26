{ config, lib, ... }:
{
  domains = [
    rec {
      domain = "ltn.pw";
      registrar = "porkbun";
      providers = [ "gcore" ];
      dnssec = true;
      records = lib.flatten [
        {
          recordType = "fakeALIAS";
          name = "@";
          target = "terrahost";
          ttl = "10m";
        }
        {
          recordType = "HTTPS";
          name = "@";
          priority = 1;
          target = ".";
          modifiers = "alpn=h3,h2";
        }
        {
          recordType = "CNAME";
          name = "pb.${domain}.";
          target = "hetzner-de.ltn.pw.";
          ttl = "10m";
        }
        {
          recordType = "CNAME";
          name = "pl.${domain}.";
          target = "xddxdd.duckdns.org.";
          ttl = "10m";
        }
        {
          recordType = "CNAME";
          name = "www";
          target = "terrahost.ltn.pw.";
          ttl = "10m";
        }

        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal "${domain}.")
        (config.common.records.Autoconfig "${domain}.")
        config.common.records.Email
        {
          recordType = "CNAME";
          name = "E3zg58ql3SpvhP9wkHhNZTCC5HYk4l8X._domainkey";
          target = "E3zg58ql3SpvhP9wkHhNZTCC5HYk4l8X.ltn.pw.dkim.nrt1.oracleemaildelivery.com.";
          ttl = "5m";
        }
        {
          recordType = "TXT";
          name = "ahasend._domainkey";
          contents = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwjSObSm+ch+tsdVpd/XlENiMpjSjZKuvq/rLfjRXrO0vEJju12kP8yiSKMYVH1pXDu+pgQlN1QZ+Iddz8hYGWqne3QXxvu9h9v78TOBhbUvMWZ27KFFJMRaa3LtlEJ43WtO9RxDheKwT2XYVAcbVPMj3deGkS/3/POTX7C1XXcI+P/82egPJhXD5lulfa9eMOMuBOAlrEH5NFteWMd6x0dlNlbA8DzklRnrlA6HTkUi6CAOe5wCx7Wl8VbgiF95McXla/1X4pBwqyrlN1Ou95MS/fBVyRTAhGjtxDOVRlXTNIN2yo3P+owG4E4mtV62DHlfs8PEATAPdHsaSl6mE2QIDAQAB";
        }
        config.common.records.Libravatar
        config.common.records.ProxmoxCluster
        config.common.records.SIP
        (config.common.hostRecs.LTNet "ltnet.${domain}.")
        (config.common.hostRecs.DN42 "dn42.${domain}.")
        (config.common.hostRecs.NeoNetwork "neo.${domain}.")

        {
          recordType = "TXT";
          name = "@";
          contents = "google-site-verification=Yam2tN9AuaNbnuf_RIgizJX0bDD1l8LoMEjPE9dxvAE";
        }
      ];
    }
  ];
}
