{
  pkgs,
  lib,
  dns,
  common,
  hosts,
  ...
}:
with dns; [
  rec {
    domain = "ltn.pw";
    registrar = "porkbun";
    providers = ["cloudflare"];
    records = [
      (ALIAS {
        name = "${domain}.";
        target = "v-ps-fal.ltn.pw.";
        ttl = "10m";
      })
      (CNAME {
        name = "pb.${domain}.";
        target = "v-ps-fal.ltn.pw.";
        ttl = "10m";
      })
      (CNAME {
        name = "www.${domain}.";
        target = "v-ps-fal.ltn.pw.";
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
      common.records.GeoRecords
      (common.hostRecs.LTNet "ltnet.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")
    ];
  }
]
