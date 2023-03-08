{
  pkgs,
  lib,
  dns,
  common,
  hosts,
  ...
}:
with dns; let
  emailCloudflareRouting = [
    (MX {
      name = "@";
      priority = 99;
      target = "route1.mx.cloudflare.net.";
      ttl = 1;
    })
    (MX {
      name = "@";
      priority = 69;
      target = "route2.mx.cloudflare.net.";
      ttl = 1;
    })
    (MX {
      name = "@";
      priority = 9;
      target = "route3.mx.cloudflare.net.";
      ttl = 1;
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
in [
  rec {
    domain = "ltn.pw";
    registrar = "doh";
    providers = ["cloudflare"];
    records = [
      (dns.ALIAS {
        name = "${domain}.";
        target = "oneprovider.ltn.pw.";
        ttl = "10m";
      })
      (dns.CNAME {
        name = "www.${domain}.";
        target = "oneprovider.ltn.pw.";
        ttl = "10m";
      })

      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
      emailCloudflareRouting
      common.records.Libravatar
      common.records.SIP
      (common.hostRecs.GeoInfo {
        name = "geoinfo";
        ttl = "1h";
      })

      (common.hostRecs.LTNet "ltnet.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")
    ];
  }
]
