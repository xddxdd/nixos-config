{ pkgs, lib, dns, common, ... }:

with dns;
[
  rec {
    domain = "56631131.xyz";
    registrar = "doh";
    providers = [ "gcore" ];
    records = [
      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      common.records.Libravatar
      common.records.SIP

      (common.hostRecs.LTNet "ltnet.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")
      (common.hostRecs.Yggdrasil "ygg.${domain}")

      (A { name = "virmach-host"; address = "149.57.231.2"; })
      (A { name = "*.virmach-host"; address = "149.57.231.2"; })
      (IGNORE { name = "geo"; })

      (NS { name = "xip"; target = "ns-aws.sslip.io."; })
      (NS { name = "xip"; target = "ns-gce.sslip.io."; })
      (NS { name = "xip"; target = "ns-azure.sslip.io."; })
    ];
  }
]
