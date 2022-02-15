{ pkgs, dns, common, ... }:

[
  (rec {
    domain = "lantian.pp.ua";
    registrar = "doh";
    providers = [ "henet" "desec" ];
    records = [
      (common.apexRecords domain)
      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
    ];
  })

  (rec {
    domain = "ltn.pp.ua";
    registrar = "doh";
    providers = [ "henet" "desec" ];
    records = [
      (common.apexRecords domain)
      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
    ];
  })

  (rec {
    domain = "xuyh0120.pp.ua";
    registrar = "doh";
    providers = [ "henet" "desec" ];
    records = [
      (common.apexRecords domain)
      common.hostRecs.CAA
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
    ];
  })
]
