{ config, lib, ... }:
{
  domains = [
    rec {
      domain = "xuyh0120.com";
      providers = [ "henet" ];
      records = lib.flatten [
        {
          recordType = "ALIAS";
          name = "@";
          target = config.common.records.GeoDNSTarget;
          ttl = "10m";
        }
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
        (config.common.hostRecs.SSHFP "${domain}.")
        (config.common.records.Autoconfig "${domain}.")
        config.common.records.MXRoute
        config.common.records.Libravatar
        config.common.records.ProxmoxCluster
        config.common.records.SIP
        (config.common.hostRecs.LTNet "ltnet.${domain}.")
        (config.common.hostRecs.DN42 "dn42.${domain}.")
        (config.common.hostRecs.NeoNetwork "neo.${domain}.")
      ];
    }
  ];
}
