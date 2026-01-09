{ config, lib, ... }:
{
  domains = [
    rec {
      domain = "lantian.eu.org";
      registrar = "doh";
      providers = [
        "bind"
        "desec"
      ];
      records = lib.flatten [
        (config.common.apexRecords "${domain}.")
        (config.common.hostRecs.Normal "${domain}.")
        (config.common.hostRecs.SSHFP "${domain}.")
        config.common.nameservers.Public
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
