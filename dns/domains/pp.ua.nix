{ pkgs, lib, dns, common, ... }:

[
  rec {
    domain = "lantian.pp.ua";
    registrar = "doh";
    providers = [ "henet" "desec" ];
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
      (common.hostRecs.Yggdrasil "ygg.${domain}")
    ];
  }

  rec {
    domain = "ltn.pp.ua";
    registrar = "doh";
    providers = [ "henet" "desec" ];
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
      (common.hostRecs.Yggdrasil "ygg.${domain}")
    ];
  }

  rec {
    domain = "xuyh0120.pp.ua";
    registrar = "doh";
    providers = [ "henet" "desec" ];
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
      (common.hostRecs.Yggdrasil "ygg.${domain}")
    ];
  }
]
