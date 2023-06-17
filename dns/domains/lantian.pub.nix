{
  pkgs,
  lib,
  dns,
  common,
  hosts,
  ...
}:
with dns; let
  inherit (common.hostRecs) fakeALIAS;
  inherit (common.nameservers) PublicNSRecords;

  email = [
    (CNAME {
      name = "s1._domainkey";
      target = "s1.domainkey.u6126456.wl207.sendgrid.net.";
    })
    (CNAME {
      name = "s2._domainkey";
      target = "s2.domainkey.u6126456.wl207.sendgrid.net.";
    })
    (CNAME {
      name = "em1411";
      target = "u6126456.wl207.sendgrid.net.";
    })
    (CNAME {
      name = "url3735";
      target = "sendgrid.net.";
    })
    (CNAME {
      name = "6126456";
      target = "sendgrid.net.";
    })
  ];

  externalServices = [
    (IGNORE {name = "backblaze";}) # Handled by CF Worker
    (CNAME {
      name = "gcore";
      target = "cl-47f440a2.gcdn.co.";
    })
    (CNAME {
      name = "github-pages";
      target = "lantian1998.github.io.";
    })
    (CNAME {
      name = "netlify";
      target = "lantian.netlify.com.";
    })
    (A {
      name = "oracle-lb";
      address = "140.238.39.120";
    })
    (AAAA {
      name = "oracle-lb";
      address = "2603:c021:8000:aaaa:c15d:d2e2:da2d:af58";
    })
    (CNAME {
      name = "render";
      target = "lantian1998.onrender.com.";
    })

    # Freshping & verification
    (CNAME {
      name = "status";
      target = "statuspage.freshping.io.";
      cloudflare = true;
    })
    (CNAME {
      name = "737acf9b9d41aae168dbe658b5efada5cab2c445.status";
      target = "667076964ffd2f999aa14ff100c5467dbaee91a0.fpverify.freshping.io.";
    })

    (CNAME {
      name = "vercel";
      target = "cname.vercel-dns.com.";
    })
    (TXT {
      name = "@";
      contents = "google-site-verification=eySrj7tImhjLmyEzhvz6-esuzD2jdnQ8anx4qfIwApw";
    })
  ];

  internalServices = [
    (CNAME {
      name = "ca";
      target = "hetzner-de";
      ttl = "10m";
    })
    (CNAME {
      name = "ci";
      target = "hetzner-de";
      cloudflare = true;
    })
    (CNAME {
      name = "ci-github";
      target = "hetzner-de";
      cloudflare = true;
    })
    (CNAME {
      name = "comments";
      target = "hetzner-de";
      ttl = "10m";
    })
    (CNAME {
      name = "git";
      target = "hetzner-de";
      ttl = "10m";
    })
    (CNAME {
      name = "gopher";
      target = "v-ps-sjc";
      ttl = "10m";
    })
    (CNAME {
      name = "lab";
      target = "hetzner-de";
      ttl = "10m";
    })
    (CNAME {
      name = "lg";
      target = "hetzner-de";
      cloudflare = true;
    })
    (CNAME {
      name = "login";
      target = "hetzner-de";
      ttl = "10m";
    })
    (fakeALIAS {
      name = "matrix";
      target = "hetzner-de";
      ttl = "10m";
    })
    (SRV {
      name = "_matrix._tcp";
      priority = 10;
      weight = 0;
      port = 8448;
      target = "matrix";
    })
    (CNAME {
      name = "tools";
      target = common.records.GeoDNSTarget;
      ttl = "10m";
    })
    (CNAME {
      name = "whois";
      target = "v-ps-sjc";
      ttl = "10m";
    })

    (PublicNSRecords "asn")
    (DS {
      name = "asn";
      keytag = 48539;
      algorithm = 13;
      digesttype = 2;
      digest = "7D653B29D41EDF8A607B3119AF7FF3F0C1AE6EBFD19AA6FA1CCF1590E74DE1B6";
      ttl = "1d";
    })
    (DS {
      name = "asn";
      keytag = 48539;
      algorithm = 13;
      digesttype = 4;
      digest = "0F8035F6A9BF09C806FE665445524632ADFA53E23BFB225E2128963ADAAD5B18294831A345A0AE06FA42E9217DEA0E2A";
      ttl = "1d";
    })

    # Active Directory
    (PublicNSRecords "ad")

    # SSL tests
    (CNAME {
      name = "buypass-ssl";
      target = common.records.GeoDNSTarget;
      ttl = "10m";
    })
    (CNAME {
      name = "google-ssl";
      target = common.records.GeoDNSTarget;
      ttl = "10m";
    })
    (CNAME {
      name = "google-test-ssl";
      target = common.records.GeoDNSTarget;
      ttl = "10m";
    })
    (CNAME {
      name = "letsencrypt-ssl";
      target = common.records.GeoDNSTarget;
      ttl = "10m";
    })
    (CNAME {
      name = "letsencrypt-test-ssl";
      target = common.records.GeoDNSTarget;
      ttl = "10m";
    })
    (CNAME {
      name = "zerossl";
      target = common.records.GeoDNSTarget;
      ttl = "10m";
    })
  ];
in [
  rec {
    domain = "lantian.pub";
    registrar = "doh";
    providers = ["cloudflare"];
    records = [
      (dns.ALIAS {
        name = "${domain}.";
        target = common.records.GeoDNSTarget;
        ttl = "10m";
      })
      (dns.CNAME {
        name = "www.${domain}.";
        target = common.records.GeoDNSTarget;
        ttl = "10m";
      })

      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
      (common.records.Autoconfig domain)
      common.records.MXRoute
      (TXT {
        name = "_token._dnswl";
        contents = "xdyg6y366ui8ihelglmjjtxhtpd7rivm";
      })
      common.records.Libravatar
      common.records.SIP
      (common.hostRecs.GeoInfo {
        name = "geoinfo";
        ttl = "10m";
      })
      (TXT {
        name = "@";
        contents = "MS=ms22955481";
      })

      (common.hostRecs.LTNet "ltnet.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")

      email
      externalServices
      internalServices
    ];
  }
]
