{ config, lib, ... }:
let
  inherit (config.common.nameservers) PublicNSRecords;

  externalServices = [
    {
      recordType = "CNAME";
      name = "gcore";
      target = "cl-47f440a2.gcdn.co.";
    }
    {
      recordType = "CNAME";
      name = "github-pages";
      target = "lantian1998.github.io.";
    }
    {
      recordType = "CNAME";
      name = "netlify";
      target = "lantian.netlify.com.";
    }
    {
      recordType = "A";
      name = "oracle-lb";
      address = "131.186.33.1";
    }
    {
      recordType = "AAAA";
      name = "oracle-lb";
      address = "2603:c021:8000:aaaa:ec00:e71d:1fd4:3d48";
    }
    {
      recordType = "A";
      name = "oracle-nlb";
      address = "140.238.39.120";
    }
    {
      recordType = "AAAA";
      name = "oracle-nlb";
      address = "2603:c021:8000:aaaa:c15d:d2e2:da2d:af58";
    }
    {
      recordType = "CNAME";
      name = "render";
      target = "lantian1998.onrender.com.";
    }
    {
      recordType = "CNAME";
      name = "vercel";
      target = "cname.vercel-dns.com.";
    }
    {
      recordType = "TXT";
      name = "@";
      contents = "google-site-verification=eySrj7tImhjLmyEzhvz6-esuzD2jdnQ8anx4qfIwApw";
    }
    {
      recordType = "CNAME";
      name = "edgeone";
      target = "edgeone.lantian.pub.eo.dnse4.com.";
    }
    {
      recordType = "TXT";
      name = "edgeonereclaim";
      contents = "reclaim-eo4oqvr506l0vfbfml5ndq7hk38weoxq";
    }
  ];

  internalServices = [
    {
      recordType = "CNAME";
      name = "api";
      target = config.common.records.GeoDNSTarget;
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "ca";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "comments";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "element";
      # GeoDNS target for servers with sufficient storage
      target = "tools";
    }
    {
      recordType = "CNAME";
      name = "flapalerted";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "git";
      target = "terrahost";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "gopher";
      target = config.common.records.GeoDNSTarget;
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "lab";
      target = "terrahost";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "lemmy";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "lg";
      target = "colocrossing";
    }
    {
      recordType = "CNAME";
      name = "login";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "fakeALIAS";
      name = "matrix";
      target = "colocrossing";
      ttl = "1h";
    }
    {
      recordType = "SRV";
      name = "_matrix._tcp";
      priority = 10;
      weight = 0;
      port = 8448;
      target = "matrix";
    }
    {
      recordType = "CNAME";
      name = "sip";
      target = "v-ps-sea";
      ttl = "1h";
    }
    {
      recordType = "GEO";
      # GeoDNS for servers with sufficient storage
      name = "tools";
      ttl = "5m";
      filter = n: v: (v.hasTag "server") && (v.hasTag "public-facing") && (!(v.hasTag "low-disk"));
      healthcheck = "tools.lantian.pub";
    }
    {
      recordType = "CNAME";
      name = "whois";
      target = config.common.records.GeoDNSTarget;
      ttl = "1h";
    }

    (PublicNSRecords "asn")
    # # GCore doesn't support DS records
    # {
    #   recordType = "DS";
    #   name = "asn";
    #   keytag = 48539;
    #   algorithm = 13;
    #   digesttype = 2;
    #   digest = "7D653B29D41EDF8A607B3119AF7FF3F0C1AE6EBFD19AA6FA1CCF1590E74DE1B6";
    #   ttl = "1h";
    # }
    # {
    #   recordType = "DS";
    #   name = "asn";
    #   keytag = 48539;
    #   algorithm = 13;
    #   digesttype = 4;
    #   digest = "0F8035F6A9BF09C806FE665445524632ADFA53E23BFB225E2128963ADAAD5B18294831A345A0AE06FA42E9217DEA0E2A";
    #   ttl = "1h";
    # }

    # Active Directory
    (PublicNSRecords "ad")

    # SSL tests
    {
      recordType = "CNAME";
      name = "google-ssl";
      target = config.common.records.GeoDNSTarget;
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "google-test-ssl";
      target = config.common.records.GeoDNSTarget;
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "letsencrypt-ssl";
      target = config.common.records.GeoDNSTarget;
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "letsencrypt-test-ssl";
      target = config.common.records.GeoDNSTarget;
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "zerossl";
      target = config.common.records.GeoDNSTarget;
      ttl = "1h";
    }
  ];
in
{
  domains = [
    rec {
      domain = "lantian.pub";
      registrar = "porkbun";
      providers = [ "gcore" ];
      dnssec = true;
      records = lib.flatten [
        {
          recordType = "GEO";
          # GeoDNS for public facing servers
          name = "@";
          ttl = "5m";
          filter = n: v: (v.hasTag "server") && (v.hasTag "public-facing");
          healthcheck = "lantian.pub";
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
          name = "www";
          target = "@";
          ttl = "5m";
        }

        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal "${domain}.")
        (config.common.records.Autoconfig "${domain}.")
        config.common.records.Email
        {
          recordType = "CNAME";
          name = "ovh8aTSUCDYt9UEJadhoo5CCoM3zPgdg._domainkey";
          target = "ovh8aTSUCDYt9UEJadhoo5CCoM3zPgdg.lantian.pub.dkim.nrt1.oracleemaildelivery.com.";
        }
        {
          recordType = "TXT";
          name = "ahasend._domainkey";
          contents = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqRA74/KFh5TJqHCUaOJBTSQ1UbBUIeOY0LSjmSeFMWYnYfnXOaJgbHRGkSDi/SdCwW05M276B5g7kZKEpfvO0cFnHu6Olk806YaBj2zx8WG3tdH70YdGllY00EZbJPER9s/kY5CuCY1IiNkPsECasI6GIA5BtvCzdV8YtcyCKDb78ACEwY8TZrvEbgmxUMppp50JK1VR8xtvCs0yqg/ewyXsOVcpeGBNkpqtwmaXa3mNC491aHtVQqyT0+Zgjm4XmqJPKSY4qT/m6QoKCZgR6z64nw0Lzn6e+pPbRiYmMY39R5VZZgBR3mjHiCsfycI7ZVGRtHKjwObjF5ZcalAe7wIDAQAB";
        }
        {
          recordType = "TXT";
          name = "_token._dnswl";
          contents = "xdyg6y366ui8ihelglmjjtxhtpd7rivm";
        }
        config.common.records.Libravatar
        config.common.records.SIP

        {
          recordType = "TXT";
          name = "@";
          contents = "MS=ms22955481";
        }

        (config.common.hostRecs.LTNet "ltnet.${domain}.")
        (config.common.hostRecs.DN42 "dn42.${domain}.")
        (config.common.hostRecs.NeoNetwork "neo.${domain}.")

        externalServices
        internalServices
      ];
    }
  ];
}
