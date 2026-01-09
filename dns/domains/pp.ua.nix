{ config, lib, ... }:
{
  domains = [
    rec {
      domain = "lantian.pp.ua";
      registrar = "doh";
      providers = [
        "henet"
        "desec"
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

        {
          recordType = "AAAA";
          name = "manosaba";
          address = "2001:470:8c19::14";
        }
      ];
    }

    rec {
      domain = "ltn.pp.ua";
      registrar = "doh";
      providers = [
        "henet"
        "desec"
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

        {
          recordType = "AAAA";
          name = "manosaba";
          address = "2001:470:8c19::14";
        }
      ];
    }

    rec {
      domain = "xuyh0120.pp.ua";
      registrar = "doh";
      providers = [
        "henet"
        "desec"
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

        {
          recordType = "AAAA";
          name = "manosaba";
          address = "2001:470:8c19::14";
        }
      ];
    }
  ];
}
