{ config, lib, ... }:
{
  domains = [
    rec {
      domain = "ltn.us.kg";
      registrar = "doh";
      providers = [
        "henet"
      ];
      records = lib.flatten [
        (config.common.apexRecords "${domain}.")
        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal "${domain}.")
        (config.common.hostRecs.SSHFP "${domain}.")
        config.common.records.Libravatar
        config.common.records.SIP

        (config.common.hostRecs.LTNet "ltnet.${domain}.")
        (config.common.hostRecs.DN42 "dn42.${domain}.")
        (config.common.hostRecs.NeoNetwork "neo.${domain}.")
      ];
    }
  ];
}
