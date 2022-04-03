{ pkgs, lib, dns, common, ... }:

[
  (rec {
    domain = "lantian.eu.org";
    registrar = "doh";
    providers = [ "bind" "desec" ];
    records = [
      (common.apexRecords domain)
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
      common.nameservers.Public
    ];
  })
]
