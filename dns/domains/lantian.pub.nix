{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
} @ args: let
  inherit (config.common.nameservers) PublicNSRecords;

  email = [
    {
      recordType = "CNAME";
      name = "s1._domainkey";
      target = "s1.domainkey.u6126456.wl207.sendgrid.net.";
    }
    {
      recordType = "CNAME";
      name = "s2._domainkey";
      target = "s2.domainkey.u6126456.wl207.sendgrid.net.";
    }
    {
      recordType = "CNAME";
      name = "em1411";
      target = "u6126456.wl207.sendgrid.net.";
    }
    {
      recordType = "CNAME";
      name = "url3735";
      target = "sendgrid.net.";
    }
    {
      recordType = "CNAME";
      name = "6126456";
      target = "sendgrid.net.";
    }
  ];

  externalServices = [
    {
      recordType = "IGNORE";
      name = "backblaze";
    } # Handled by CF Worker
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
  ];

  internalServices = [
    {
      recordType = "CNAME";
      name = "ca";
      target = "v-ps-fal";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "ci";
      target = "v-ps-fal";
    }
    {
      recordType = "CNAME";
      name = "ci-github";
      target = "v-ps-fal";
    }
    {
      recordType = "CNAME";
      name = "comments";
      target = "v-ps-fal";
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
      target = "v-ps-sjc";
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
      target = "v-ps-fal";
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "lg";
      target = "v-ps-fal";
    }
    {
      recordType = "CNAME";
      name = "login";
      target = "v-ps-fal";
      ttl = "1h";
    }
    {
      recordType = "fakeALIAS";
      name = "matrix";
      target = "v-ps-fal";
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
      name = "tools";
      target = config.common.records.GeoStorDNSTarget;
      ttl = "1h";
    }
    {
      recordType = "CNAME";
      name = "whois";
      target = "v-ps-sjc";
      ttl = "1h";
    }

    (PublicNSRecords "asn")
    {
      recordType = "DS";
      name = "asn";
      keytag = 48539;
      algorithm = 13;
      digesttype = 2;
      digest = "7D653B29D41EDF8A607B3119AF7FF3F0C1AE6EBFD19AA6FA1CCF1590E74DE1B6";
      ttl = "1h";
    }
    {
      recordType = "DS";
      name = "asn";
      keytag = 48539;
      algorithm = 13;
      digesttype = 4;
      digest = "0F8035F6A9BF09C806FE665445524632ADFA53E23BFB225E2128963ADAAD5B18294831A345A0AE06FA42E9217DEA0E2A";
      ttl = "1h";
    }

    # Active Directory
    (PublicNSRecords "ad")

    # SSL tests
    {
      recordType = "CNAME";
      name = "buypass-ssl";
      target = config.common.records.GeoDNSTarget;
      ttl = "1h";
    }
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
in {
  domains = [
    rec {
      domain = "lantian.pub";
      registrar = "porkbun";
      providers = ["cloudflare"];
      records = lib.flatten [
        {
          recordType = "ALIAS";
          name = "${domain}.";
          target = config.common.records.GeoDNSTarget;
          ttl = "10m";
        }
        {
          recordType = "CNAME";
          name = "www.${domain}.";
          target = config.common.records.GeoDNSTarget;
          ttl = "10m";
        }

        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal domain)
        (config.common.hostRecs.SSHFP domain)
        (config.common.records.Autoconfig domain)
        config.common.records.MXRoute
        {
          recordType = "TXT";
          name = "_token._dnswl";
          contents = "xdyg6y366ui8ihelglmjjtxhtpd7rivm";
        }
        config.common.records.Libravatar
        config.common.records.ProxmoxCluster
        config.common.records.SIP
        config.common.records.GeoRecords

        {
          recordType = "TXT";
          name = "@";
          contents = "MS=ms22955481";
        }

        (config.common.hostRecs.LTNet "ltnet.${domain}")
        (config.common.hostRecs.DN42 "dn42.${domain}")
        (config.common.hostRecs.NeoNetwork "neo.${domain}")

        email
        externalServices
        internalServices
      ];
    }
  ];
}
