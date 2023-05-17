{
  pkgs,
  lib,
  dns,
  common,
  ...
}: [
  rec {
    domain = "lantian.rr.nu";
    registrar = "doh";
    providers = ["henet"];
    records = [
      (common.apexRecords domain)
      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
      common.records.Libravatar
      common.records.SIP

      (common.hostRecs.LTNet "ltnet.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")
    ];
  }
]
