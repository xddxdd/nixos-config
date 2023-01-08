{ pkgs, lib, dns, common, ... }:

with dns;
let
  inherit (common.hostRecs) fakeALIAS;
in
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

      (fakeALIAS { name = "${domain}."; target = "oneprovider"; ttl = "1h"; })
      (CNAME { name = "www.${domain}."; target = "${domain}."; })

      (A { name = "virmach-host"; address = "31.222.203.3"; })
      (A { name = "*.virmach-host"; address = "31.222.203.3"; })
      (IGNORE { name = "geo"; })

      (NS { name = "xip"; target = "ns-aws.sslip.io."; })
      (NS { name = "xip"; target = "ns-gce.sslip.io."; })
      (NS { name = "xip"; target = "ns-azure.sslip.io."; })

      (TXT { name = "@"; contents = "google-site-verification=LQvBzSL4-2NbbqM2208pYGLsRSw_hw132GGUvnShQGU"; })
    ];
  }
]
