{
  pkgs,
  lib,
  dns,
  common,
  hosts,
  ...
}: [
  rec {
    domain = "ltn.pw";
    registrar = "doh";
    providers = ["cloudflare"];
    records = [
      (dns.ALIAS {
        name = "${domain}.";
        target = "hetzner-de.ltn.pw.";
        ttl = "10m";
      })
      (dns.CNAME {
        name = "pb.${domain}.";
        target = "hetzner-de.ltn.pw.";
        ttl = "10m";
      })
      (dns.CNAME {
        name = "www.${domain}.";
        target = "hetzner-de.ltn.pw.";
        ttl = "10m";
      })

      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
      (common.records.Autoconfig domain)
      common.records.MXRoute
      common.records.Libravatar
      common.records.ProxmoxCluster
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
