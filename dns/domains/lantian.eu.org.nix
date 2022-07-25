{ pkgs, lib, dns, common, ... }:

[
  rec {
    domain = "lantian.eu.org";
    registrar = "doh";
    providers = [ "bind" "desec" ];
    records = [
      (common.apexRecords domain)
      (common.hostRecs.Normal domain)
      (common.hostRecs.SSHFP domain)
      common.nameservers.Public
      common.records.Libravatar

      (common.hostRecs.LTNet "ltnet.${domain}")
      (common.hostRecs.DN42 "dn42.${domain}")
      (common.hostRecs.NeoNetwork "neo.${domain}")
      (common.hostRecs.Yggdrasil "ygg.${domain}")
    ];
  }
]
