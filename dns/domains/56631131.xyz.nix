{
  pkgs,
  lib,
  dns,
  common,
  ...
}:
with dns; let
  inherit (common.hostRecs) fakeALIAS;
in [
  rec {
    domain = "56631131.xyz";
    registrar = "porkbun";
    providers = ["gcore"];
    records = [
      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      common.records.Libravatar
      common.records.SIP
      common.records.GeoRecords
      (common.hostRecs.LTNet "ltnet.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")

      (fakeALIAS {
        name = "${domain}.";
        target = "v-ps-fal";
        ttl = "1h";
      })
      (CNAME {
        name = "www.${domain}.";
        target = "${domain}.";
      })

      (NS {
        name = "virmach-host";
        target = "ns1.vpshared.com.";
      })
      (NS {
        name = "virmach-host";
        target = "ns2.vpshared.com.";
      })

      (NS {
        name = "xip";
        target = "ns-aws.sslip.io.";
      })
      (NS {
        name = "xip";
        target = "ns-gce.sslip.io.";
      })
      (NS {
        name = "xip";
        target = "ns-azure.sslip.io.";
      })

      (TXT {
        name = "@";
        contents = "google-site-verification=LQvBzSL4-2NbbqM2208pYGLsRSw_hw132GGUvnShQGU";
      })
    ];
  }
]
