{
  pkgs,
  lib,
  dns,
  common,
  hosts,
  ...
}:
with dns; let
  inherit (common.hostRecs) hasPublicIP;

  emailCloudflareRouting = [
    (MX {
      name = "@";
      priority = 7;
      target = "isaac.mx.cloudflare.net.";
    })
    (MX {
      name = "@";
      priority = 38;
      target = "linda.mx.cloudflare.net.";
    })
    (MX {
      name = "@";
      priority = 14;
      target = "amir.mx.cloudflare.net.";
    })
    (TXT {
      name = "@";
      contents = "v=spf1 include:_spf.mx.cloudflare.net ~all";
    })
    (TXT {
      name = "@";
      contents = "v=DMARC1; p=none";
    })
    (TXT {
      name = "_dmarc";
      contents = "v=DMARC1; p=none";
    })
  ];

  externalServices = [
    (TXT {
      name = "@";
      contents = "google-site-verification=dFXi0jyD7Qm4WrRUaC79-XQWAJ4UwcdNSbGNTI9IvLg";
    })

    (CNAME {
      name = "s1._domainkey";
      target = "s1.domainkey.u6126456.wl207.sendgrid.net.";
    })
    (CNAME {
      name = "s2._domainkey";
      target = "s2.domainkey.u6126456.wl207.sendgrid.net.";
    })
    (CNAME {
      name = "em3816";
      target = "u6126456.wl207.sendgrid.net.";
    })
    (CNAME {
      name = "url9203";
      target = "sendgrid.net.";
    })
    (CNAME {
      name = "6126456";
      target = "sendgrid.net.";
    })
  ];

  internalServices = [
    (CNAME {
      name = "asf";
      target = "hetzner-de";
      ttl = "1h";
    })
    (CNAME {
      name = "books";
      target = "servarica";
      ttl = "1h";
    })
    (CNAME {
      name = "bitwarden";
      target = "hetzner-de";
      ttl = "1h";
    })
    (CNAME {
      name = "cloud";
      target = "hetzner-de";
      ttl = "1h";
    })
    (CNAME {
      name = "dashboard";
      target = "hetzner-de";
      ttl = "1h";
    })
    (CNAME {
      name = "lab";
      target = "lab.lantian.pub.";
      ttl = "1h";
    })
    (CNAME {
      name = "login";
      target = "hetzner-de";
      ttl = "1h";
    })
    (CNAME {
      name = "private";
      target = "hetzner-de.ltnet.xuyh0120.win.";
      ttl = "1h";
    })
    (CNAME {
      name = "rss";
      target = "hetzner-de";
      ttl = "1h";
    })
    (CNAME {
      name = "stats";
      target = "hetzner-de";
      ttl = "1h";
    })
    (CNAME {
      name = "vault";
      target = "hetzner-de";
      ttl = "1h";
    })
  ];
in [
  rec {
    domain = "xuyh0120.win";
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
      emailCloudflareRouting
      (TXT {
        name = "_token._dnswl";
        contents = "qcq5l789ndevk0jawrgcah0f5s4ld8sz";
      })
      common.records.Libravatar
      common.records.SIP
      (common.hostRecs.GeoInfo {
        name = "geoinfo";
        ttl = "1h";
      })

      (common.hostRecs.LTNet "ltnet.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")

      externalServices
      internalServices
    ];
  }
]
