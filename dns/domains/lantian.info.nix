{ config, lib, ... }:
{
  domains = [
    rec {
      domain = "lantian.info";
      providers = [ "bunny" ];
      records = lib.flatten [
        (config.common.records.GeoScriptedServers "@")
        {
          recordType = "HTTPS";
          name = "@";
          priority = 1;
          target = ".";
          modifiers = "alpn=h3,h2";
        }
        {
          recordType = "CNAME";
          name = "www";
          target = config.common.records.GeoDNSTarget;
          ttl = "10m";
        }

        config.common.hostRecs.CAA
        (config.common.hostRecs.Normal "${domain}.")
        (config.common.records.Autoconfig "${domain}.")
        config.common.records.Email
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
